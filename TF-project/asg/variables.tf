variable "name" { type = "string" }
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "az1" {} 
variable "az2" {}
variable "launch_template_id" {}
variable "protect_scalein" { type = bool }
variable "tags" {
  type = list(map(string))
}
variable "cooldown" { default = 300 }
variable "termination_policies" { default = "Default"}