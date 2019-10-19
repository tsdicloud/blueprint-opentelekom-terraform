variable "instance_name" {
  description = "Used to populate the Name tag. This is done in main.tf"
}

variable "subnet_id" {
  description = "Unused on OTC"
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add"
  type        = "map"
}

variable "security_groups" {
  type = "list"
}

// --- OTC specific variables ---
variable "otc_vpc" {
  description = "VPC that has access to the OTC SFS"
  default     = ""
}

variable "otc_sfs_size" {
  description = "Size of the shared gile system"
  default     = "100"
}
