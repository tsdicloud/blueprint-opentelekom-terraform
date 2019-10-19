###
# Topo handling (new)
variable "topo_file" {
  type        = "string"
  description = "Path to topo.json"
  default     = "./topo.json"
}

variable "main_service" {
  type    = "string"
  default = "Name of the primary service on a server. It is the first name listed under contents"
  default = "none"
}

###
# topo.json requires default values set. "<topo>" is used as mark and dummy.
variable "allocated_storage" {
  description = "<topo>"
  type        = "string"
  default     = 300
}

variable "auto_minor_version_upgrade" {
  description = "<topo>"
  type        = "string"
  default     = "false"
}

variable "backup_retention_period" {
  description = "<topo> The days to retain backups for."
  type        = "string"
  default     = "30"
}

variable "backup_window" {
  description = "<topo> The daily time range (in UTC) during which automated backups are created if they are enabled. Note that OTC only accepts a start time and performs the operation within an hour. Date format including seconds is crucial."
  type        = "string"
  default     = "01:46:00"
}

variable "db_subnet_group_name" {
  description = ""
  type        = "string"
}

variable "engine_version" {
  description = "<topo>"
  type        = "string"
  default     = "5.7.20"
}

variable "identifier" {
  description = "The name of the RDS instance. It forces new resource. If omitted, Terraform will assign a random, unique identifier."
  type        = "string"
}

variable "instance_class" {
  description = "<topo>"
  type        = "string"
  default     = "<topo>"
}

variable "iops" {
  description = "<topo>"
  type        = "string"
  default     = 0
}

variable "kms_key_id" {
  default = ""
}

variable "maintenance_window" {
  description = "<topo> The window to perform maintenance in."
  type        = "string"
  default     = "Sat:00:00"
}

variable "multi_az" {
  description = "<topo>If the RDS instance is multi AZ enabled."
  type        = "string"
  default     = "false"
}

variable "OWNEREMAIL" {
  description = "Set the owner of this AWS instance"
  type        = "string"
  default     = "jstang@terra.com"
}

variable "parameter_group_name" {
  description = "<topo>"
  type        = "string"
  default     = "<topo>"
}

variable "password" {
  description = "<topo>"
  type        = "string"
  default     = "<topo> TODO:to wallet"
}

variable "securitygroups" {
  description = "VPC security group ids associated with new db instance"
  type        = "list"
}

variable "skip_final_snapshot" {
  description = "<topo>Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = "string"
  default     = "true"
}

variable "storage_encrypted" {
  description = "<topo>"
  type        = "string"
  default     = "false"
}

variable "storage_type" {
  description = "<topo>One of COMMON|ULTRAHIGH"
  default     = "COMMON"
}

variable "username" {
  description = "<topo>"
  type        = "string"
  default     = "root"
}

variable "tags" {
  type = "map"
}

###
# OTC specific variables
variable "otc_region" {
  type        = "string"
  description = "Required for query of DB flavorson r"
}

variable "otc_vpc" {
  type        = "string"
  description = "OTC requires VPC for RDS creation and the value could not be derived from subnet"
}

variable "otc_db_primary_az" {
  type        = "string"
  description = "OTC requires to set a primary availability zone fpr the db"
}

variable "otc_token" {
  type        = "string"
  description = "Open Telekom Cloud token for DNS registration workaround"
}
