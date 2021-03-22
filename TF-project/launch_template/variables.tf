variable "name" { type = "string" }
variable "ecs_iam_role" { type = string }
variable "image_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "security_group_ids" { type = list(string) }
variable "tags" { type = map(string) }
variable "userdata" { default = "" }
