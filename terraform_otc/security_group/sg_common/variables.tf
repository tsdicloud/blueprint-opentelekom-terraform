variable "cidr_blocks_mgmt" {
  description = "CIDR block used by mgmt zone"
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

variable "tsys_sg_mgmt" {
  description = "Name of the mgmt vpc"
  type        = "string"
  default     = "DOAAS-MGMT-SG"
}
