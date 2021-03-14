 locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.elasticache_subnets),
    length(var.database_subnets),
    length(var.redshift_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = element(
    concat(
      aws_vpc_ipv4_cidr_block_association.this.*.vpc_id,
      aws_vpc.this.*.id,
      [""],
    ),
    0,
  )
}


######
# VPC
######
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = aws_vpc.this[0].id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

resource "aws_internet_gateway" "liferay_igw" {

  vpc_id = local.vpc_id

}


################
# Public routes
################
resource "aws_route_table" "public" {

  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.liferay_igw.id
  }

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
    var.tags,
    var.public_route_table_tags,
  )
}

#################
# Private routes
#################
resource "aws_route_table" "private" {

  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0
  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}", var.name)
    },
    var.tags,
    var.private_route_table_tags,
  )
}

###############
#squid gateway
###############

/*resource "aws_network_interface" "squid_eni" {
  #count             = var.squid_server_count
  count             = 1
  subnet_id         = aws_subnet.public[1].id
  source_dest_check = false
  
  #subnet_id         = element(aws_subnet.public.*.id, count.index)
  #security_groups   = [aws_security_group.squid-sg.id]

  tags = var.tags

}*/

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0

  vpc_id                  = local.vpc_id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format(
        element(var.public_subnet_name, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format(
        element(var.private_subnet_name, count.index),
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}


########################
#route table association
########################


resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {

  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

######################
# VPC Endpoint for S3
######################

data "aws_vpc_endpoint_service" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0
  #count   = 1  
  service = "s3"
  service_type = "Gateway"

}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id       = local.vpc_id
  #service_name = data.aws_vpc_endpoint_service.s3[0].service_name
  service_name = "com.amazonaws.us-east-1.s3"
  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::liferay-2020-gc",
                "arn:aws:s3:::liferay-2020-gc/*",
                "arn:aws:s3:::prod-us-east-1-starport-layer-bucket/*"
            ]
        }
    ]
}
POLICY

 tags = merge(
    {
      "Name" = "Liferay_S3"
    },
    var.tags,
    var.vpc_tags,
  )
}


resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

/*resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}*/


###########################
# VPC Endpoint for ECR API
###########################
data "aws_vpc_endpoint_service" "ecr_api" {
  count = var.create_vpc && var.enable_ecr_api_endpoint ? 1 : 0

  service = "ecr.api"
}

resource "aws_vpc_endpoint" "ecr_api" {
  count = var.create_vpc && var.enable_ecr_api_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_api[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ecr_api_endpoint_security_group_ids
  subnet_ids          = [aws_subnet.public[1].id]
  /*subnet_ids          = coalescelist(var.ecr_api_endpoint_subnet_ids, aws_subnet.private.*.id )*/
  private_dns_enabled = var.ecr_api_endpoint_private_dns_enabled

  tags = merge(
    {
      "Name" = "Liferay_ECR_API"
    },
    var.tags,
    var.vpc_tags,
  )
}

###########################
# VPC Endpoint for ECR DKR
###########################
data "aws_vpc_endpoint_service" "ecr_dkr" {
  count = var.create_vpc && var.enable_ecr_dkr_endpoint ? 1 : 0

  service = "ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.create_vpc && var.enable_ecr_dkr_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_dkr[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ecr_dkr_endpoint_security_group_ids
  subnet_ids          = [aws_subnet.public[1].id]
  /*subnet_ids          = coalescelist(var.ecr_dkr_endpoint_subnet_ids, aws_subnet.private.*.id )*/
  private_dns_enabled = var.ecr_dkr_endpoint_private_dns_enabled

  tags = merge(
    {
      "Name" = "Liferay_ECR_DKR"
    },
    var.tags,
    var.vpc_tags,
  )
}

#################
#aws route
#################
resource "aws_route" "private_squid_gateway" {
  count                  = var.enable_squid_gateway ? local.max_subnet_length : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.interface_id, count.index)

  timeouts {
    create = "5m"
  }

   lifecycle {
    ignore_changes = [
      network_interface_id,
    ]
  }
}
