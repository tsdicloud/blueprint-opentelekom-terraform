variable "cidr_blocks_ma" {
  description = "CIDR block used by ma-pod"
}

variable "cidr_blocks_nagios" {
  description = "CIDR block used by Nagios server"
}

variable "cidr_blocks_pod" {
  description = "CIDR block used by current pod"
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
