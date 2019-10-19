###
# Topo handling (new)
variable "topo_file" {
  type        = "string"
  description = "Path to topo.json"
  default     = "./topo.json"
}

variable "main_service" {
  type    = "string"
  default = "name of the primary service on a server. It is the first name listed under contents"
  default = "none"
}

###
# Built-in variables in alphabetic order
# topo.json requireddefault values set. "<topo>" is used as dummy
variable "ami_id" {
  type        = "map"
  description = "<topo>: Required for base image mapping."
}

variable "attach_volume" {}

variable "chef_server_url" {
  type        = "string"
  description = "Fully qualified name of chef server matching ssl certificate."
}

variable "chef_repo_dir" {
  description = "Knife only works on local chef server if call from repo-dir"
}

variable "chef_user" {
  description = "Unix user in management node for knife commands."
}

variable "chef_user_key" {}

variable "chef_env_name" {
  description = "<topo>"
  default     = "<topo>"
}

variable "run_list" {
  type        = "list"
  description = "<topo>: chef services to install"
  default     = [""]
}

variable "ebs_device_name" {
  default = "/dev/sdc"
}

variable "ebs_mount_point" {
  description = "<topo>"
  default     = "/opt"
}

variable "ebs_root_volume_iops" {
  description = "<topo>"
  default     = "100"
}

variable "ebs_root_volume_size" {
  description = "<topo>"
  default     = "30"
}

variable "ebs_root_volume_type" {
  description = "<topo>"
  default     = "SATA"
}

variable "ebs_volume_iops" {
  description = "<topo>"
  default     = "100"
}

variable "ebs_volume_size" {
  description = "<topo>"
  default     = "100"
}

variable "ebs_volume_type" {
  description = "<topo>"
  default     = "SATA"
}

variable "enable_encrypted_ebs" {
  default = "false"
}

variable "iam_instance_profile" {
  description = "<topo>: IAM role to attach to the instance."
  default     = ""
}

variable "prefix" {
  description = "<topo> usual podprefix, overridden by topo.json"
  default     = "<topo>"
}

variable "instance_name" {
  description = "<topo>: Populated from TAGS and topo.json"
  default     = "<topo>"
}

variable "instance_type" {
  description = "<topo>"
  default     = "2.2xlarge.4"
}

variable "key_name" {}

variable "kms_key_id" {
  default = ""
}

variable "latest_ami" {}

variable "monitoring" {
  default = "false"
}

variable "number_of_instances" {
  description = "<topo>: disable service by default"
  default     = 0
}

variable "placement_group" {
  description = "placement group"
  default     = ""
}

variable "subnets" {
  description = "The VPC subnet the instance(s) will go in"
  type        = "list"
}

variable "swap_memory" {
  description = "<topo>"
  default     = "16"
}

variable "tags" {
  description = "A map of tags to add"
  type        = "map"
}

variable "user_data" {
  description = "The path to a file with user_data for the instances"
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "The VPC security group IDs"
  type        = "list"
}

// Customized variables in alphabetic order
variable "AMIIDQUERY" {
  description = "<topo>"
  default     = "BASEAMIRHEL7"
}

variable "short_name" {}

variable "user_key" {}

variable "ec2_user" {
  type        = "string"
  description = "EC2 instance user still required"
  default     = "<topo>"
}

###
# TERRA dedicated variables ---
variable "terra_user" {
  type        = "string"
  description = "<topo>Dedicated TERRA user"
  default     = "<topo>"
}

variable "efs_ip_address" {
  type        = "string"
  description = "NFS mount address"
}

variable "mount_efs" {
  type        = "string"
  description = "<topo>Indicator to mount efs"
  default     = "false"
}

###
# OTC specific variables
variable "otc_vpc" {
  type        = "string"
  description = "VPC of server"
}

variable "otc_region" {
  type        = "string"
  description = "OTC requires region for DNS"
}

variable "otc_azs" {
  type        = "list"
  description = "OTC requires list of azs to dostribute servers"
  default     = ["eu-de-01", "eu-de-02"]
}

variable "otc_token" {
  type        = "string"
  description = "Open Telekom Cloud token for DNS registration workaround"
}
