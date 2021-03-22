output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "public_subnet_1" {
  value = [module.vpc.public_subnets[0]]
}

output "vpc_main_route_table_id" {
  value = module.vpc.vpc_main_route_table_id
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "mediawiki_target_group" {
  value = module.alb.target_group_arns[0]
}