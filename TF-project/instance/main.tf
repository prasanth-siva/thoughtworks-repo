#########
# Instance
#########

resource "aws_instance" "this" {
  count = var.instance_count

  ami           = var.ami
  key_name      = var.key_name
  instance_type = var.instance_type
  user_data     = var.user_data
  subnet_id     = element(
    distinct(compact(concat([var.subnet_id], var.subnet_ids))),
    count.index,
  )
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : var.private_ip
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ipv6_addresses
  ebs_optimized = var.ebs_optimized

  source_dest_check                    = var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  placement_group                      = var.placement_group
  tenancy                              = var.tenancy

  tags = merge(
    {
      "Name" = var.instance_count > 1 || var.use_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.tags,
  )

  volume_tags = merge(
    {
      "Name" = var.instance_count > 1 || var.use_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.volume_tags,
  )

}




