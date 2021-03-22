data "template_file" "userdata_file" {
  template = "${file("${path.module}/userdata.tpl")}"
  vars = {
    cluster_name = var.name
  }
}

resource "aws_launch_template" "launch_template" {
  name = var.name
  iam_instance_profile {
    name = var.ecs_iam_role
  }
  image_id = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  # network_interfaces {
  #   associate_public_ip_address = true
  # }
  vpc_security_group_ids = var.security_group_ids
  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }
  tag_specifications {
    resource_type = "volume"
    tags = var.tags
  }
  user_data = var.userdata == "" ? "${base64encode("${data.template_file.userdata_file.rendered}")}" : var.userdata 
  tags = var.tags
}
