variable "cidr_blocks_cr" {
  description = "CIDR block used by cross-region calls"
}

variable "cidr_blocks_ma" {
  description = "CIDR block used by ma-pod"
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

// --- OTC specific variables ---
variable "otc_vpc" {
  type        = "string"
  description = "Open Telekom Cloud requires vpc_id for server creation"
  default     = ""
}
