provider "aws" {
  region     = var.aws_region

}

resource "aws_s3_bucket" "tf_state_file" {
  bucket = "tf_state_file"
  acl    = "private"

  tags = {
    Name        = "tf_state_file"
    Environment = "Prod"
  }
}

terraform {
  backend "s3" {
    bucket = "tf_state_file"
    #"key    = "preprod/ecs-payment/preprod1.tf"
    region = "us-east-1"
    #role_arn = var.assume_role
  }
}

data "aws_ami" "mediawiki-app" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Name"
    values = [var.ami_names["mediawiki"]]

  }
}


data "aws_ami" "mediawiki-mysql" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Name"
    values = [var.ami_names["mediawiki"]]
  }
}


module "vpc" {
  source = "./network"
  #source = "git::ssh://git@bitbucket.org/gc-engineering/aws-resource.git//modules/tf-vpc?ref=master"
  name   = "mediawiki-vpc"
  cidr   = var.vpc_cidr_block

  azs                 = ["us-east-1a", "us-east-1b","us-east-1c"]
  create_route53_zone = true
  zone_name           = var.zone_name
  private_subnets     = var.private_subnets
  private_subnet_name = var.private_subnet_name
  public_subnets      = var.public_subnets
  public_subnet_name  = var.public_subnet_name
   tags = {
    usecase     = var.usecase
    environment = var.environment
    monitoring  = var.monitoring
    product     = var.product
  }

}

data "template_file" "app_user_init" {
  count    = 1
  template = "${file("${path.module}/ruserdata.tpl")}"
  vars = {
    hostname = format("%s-%d", "mediawiki-app", count.index + 1)
  }
}

# data "aws_eip" "loadtest_eip" {
#   id = var.eip_allocation_id[2]
# }

# resource "aws_eip_association" "eip_assoc2" {
#   instance_id   = module.loadtest.id[0]
#   allocation_id = var.eip_allocation_id[2]
# }


module "mediawiki-app" {
  source         = "./instance"
  name           = "mediawiki-app"
  instance_count = 1
  #ami = "ami-0ce21b51cb31a48b8"
  ami = data.aws_ami.mediawiki-app.id
  instance_type          = var.instance_type == "prod_setup" ? var.prod_setup["app"] : var.staging_setup["app"]
  key_name               = var.key_pair 
  monitoring             = false
  associate_public_ip_address = false
  subnet_ids             = [module.vpc.private_subnets[0]]
  vpc_security_group_ids = [aws_security_group.media-wiki-app.id]
  user_data              = data.template_file.app_user_init.0.rendered
  #iam_instance_profile   = var.ec2_read_iam_role

  volume_tags = {
    usecase = var.usecase
  }

  tags = {
    usecase     = var.usecase
    environment = var.environment
    product     = var.product
    service     = "mediawiki"
    Name        = "mediawiki"
  }
}

data "template_file" "mysql_user_init" {
  count    = 1
  template = "${file("${path.module}/ruserdata.tpl")}"
  vars = {
    hostname = format("%s-%d", "mediawiki-mysql", count.index + 1)
  }
}

module "mysql" {
  source         = "./instance"
  name           = "mediawiki-mysql"
  instance_count = 1
  ami = data.aws_ami.mediawiki-mysql.id
  instance_type          = var.instance_type == "prod_setup" ? var.prod_setup["mysql"] : var.staging_setup["mysql"]
  key_name               = var.key_pair
  associate_public_ip_address = false
  subnet_ids             = [module.vpc.private_subnets[2]]
  vpc_security_group_ids = [aws_security_group.media-wiki-mysql.id]
  user_data              = data.template_file.mysql_user_init.0.rendered 

  volume_tags = {
    usecase   = var.usecase
  }

  tags = {
    usecase     = var.usecase
    environment = var.environment
    product     = var.product
    service     = "mysql"
    Name        = "mediawiki-mysql"
  }

}

# module "mediawiki_launch_template" {
#  # source = "git::ssh://git@bitbucket.org/gc-engineering/aws-resource.git//modules/tf-launch-template?ref=ecs_autoscaling"
#   source = "./launch_template"
#   name = "${var.product}_${var.environment}_mediawiki"
#   image_id = data.aws_ami.liferay-es.id
#   instance_type = var.instance_type == "prod_setup" ? var.prod_setup["es"] : var.staging_setup["es"]
#   key_name = var.key_pair
#   security_group_ids = [aws_security_group.LFR_ES_sg.id,aws_security_group.LFR_common_sg.id]
#   userdata = "${base64encode("${data.template_file.mw_userdata_file.rendered}")}"
#   tags =  {
#     Name  = "${var.product}_${var.environment}_mw"
#     usecase = var.usecase
#     product = var.product
#     environment = var.environment
#     compliance = var.compliance
#     service = var.service_tags["mw"]
#     tier = var.tier_tags["application"]
#   }    
# }


# module "mediawiki_autoscaling_group" {
#   #source = "./autoscaling/auto_scaling_group"
#   source = "./asg"
#   name = "${var.product}_${var.environment}_mediawiki"
#   min_size = var.mw_min_count
#   max_size = var.mw_max_count
#   desired_capacity = var.mw_desired_count
#   protect_scalein = var.protect_scalein
#   az1 = module.vpc.private_subnets[1]
#   az2 = module.vpc.private_subnets[2]
#   launch_template_id = module.mw_launch_template.launch_template_id
#   tags = [
#     {
#       key                 = "environment"
#       value               = var.environment
#       propagate_at_launch = true
#     },
#     {
#       key                 = "product"
#       value               = var.product
#       propagate_at_launch = true
#     },
#     {
#       key                 = "usecase"
#       value               = var.usecase
#       propagate_at_launch = true
#     },
#     {
#       key                 = "monitoring"
#       value               = var.monitoring
#       propagate_at_launch = true
#     },    
#     {
#       key                 = "compliance"
#       value               = var.compliance
#       propagate_at_launch = true
#     },
#     {
#       key                 = "ddkey"
#       value               = var.ddkey
#       propagate_at_launch = true
#     },
#     {
#       key                 = "tier"
#       value               = "application"
#       propagate_at_launch = true
#     },
#   ]
# }