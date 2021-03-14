variable "createzone" {
  type        = bool
  description = "whether to create zone or not"
  default     = false
}

variable "two_vpc" {
  type        = bool
  description = "whether to create zone two_vpc or not"
  default     = false
}

variable "r53record" {
  type        = bool
  description = "whether to create record or not"
  default     = false
}


variable "tags" {
  type    = map(string)
  default = {}
}

variable "zone_name" {
  type    = string
  default = ""
}

variable "sec_vpc" {
  type    = string
  default = ""
}

variable "zone_id" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "type" {
  type    = string
  default = "A"
}

variable "records" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "ttl" {
  type    = string
  default = "300"
}
