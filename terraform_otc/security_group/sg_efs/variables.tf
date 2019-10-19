variable "cidr_blocks_pod" {
  description = "CIDR block used by current pod"
  type        = "string"
}

variable "sg_name" {
  description = "Security Group Name"
  type        = "string"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = "string"
}

variable "tags" {
  type = "map"
}
