output "cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_vpc.this.*.cidr_block, [""])[0]
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = concat(aws_vpc.this.*.instance_tenancy, [""])[0]
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = concat(aws_vpc.this.*.enable_dns_support, [""])[0]
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = concat(aws_vpc.this.*.enable_dns_hostnames, [""])[0]
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

output "name" {
  description = "The name of the VPC specified as argument to this module"
  value       = var.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.this.*.id, [""])[0]
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = concat(aws_vpc.this.*.main_route_table_id, [""])[0]
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = aws_vpc_ipv4_cidr_block_association.this.*.cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public.*.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private.*.id
}


# VPC Endpoints
output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = concat(aws_vpc_endpoint.s3.*.id, [""])[0]
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = concat(aws_vpc_endpoint.s3.*.prefix_list_id, [""])[0]
}

output "vpc_endpoint_ecr_api_id" {
  description = "The ID of VPC endpoint for ECR API"
  value       = concat(aws_vpc_endpoint.ecr_api.*.id, [""])[0]
}

output "vpc_endpoint_ecr_api_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for ECR API."
  value       = flatten(aws_vpc_endpoint.ecr_api.*.network_interface_ids)
}

output "vpc_endpoint_ecr_api_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for ECR API."
  value       = flatten(aws_vpc_endpoint.ecr_api.*.dns_entry)
}

output "r53_zone_id" {
  value =  aws_route53_zone.main.0.id
}