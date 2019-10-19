// Built-in variables in alphabetic order

variable "ami_id" {
  description = "The AMI to use"
  default     = ""
}

variable "attach_volume" {}

variable "chef_server_url" {
  type        = "string"
  description = "Fully qualified name of chef server matching ssl certificate."
}

variable "chef_repo_dir" {
  description = "Knife only works on local chef server if call from repo-dir"
}

variable "chef_env_name" {
  description = "Name of the chef environment"
}

variable "run_list" {
  type = "list"
}

variable "chef_user" {
  description = "Unix user in management node for knife commands."
}

variable "chef_user_key" {}

variable "ebs_device_name" {
  default = "/dev/sdc"
}

variable "ebs_root_volume_iops" {
  default = "100"
}

variable "ebs_root_volume_size" {
  default = ""
}

variable "ebs_root_volume_type" {
  default = "SATA"
}

variable "ebs_volume_iops" {
  default = "100"
}

variable "ebs_volume_size" {
  default = ""
}

variable "ebs_volume_type" {
  default = "SATA"
}

variable "ebs_mount_point" {
  default = "/opt"
}

variable "enable_encrypted_ebs" {
  default = "false"
}

variable "iam_instance_profile" {
  description = "iam role to attach to the instance"
  default     = ""
}

variable "instance_name" {
  description = "Used to populate the Name tag. This is done in main.tf"
}

variable "instance_type" {}

variable "key_name" {}

variable "kms_key_id" {
  default = ""
}

variable "latest_ami" {}

variable "monitoring" {
  default = "false"
}

variable "number_of_instances" {
  default = 0
}

variable "placement_group" {
  description = "placement group"
  default     = ""
}

variable "subnets" {
  description = "The VPC subnet the instance(s) will go in"
  type        = "list"
}

variable "swap_memory" {}

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
  default = ""
}

variable "short_name" {}

variable "user_key" {}

variable "ec2_user" {
  type        = "string"
  description = "EC2 instance user still required"
}

// --- TERRA dedicated variables ---
variable "terra_user" {
  type        = "string"
  description = "Dedicated TERRA user"
}

variable "efs_ip_address" {
  type        = "string"
  description = "NFS mount address"
}

variable "mount_efs" {
  type        = "string"
  description = "Indicator to mount efs"
}

// --- OTC specific variables ---
variable "otc_azs" {
  type        = "list"
  description = "OTC requires list of azs to dostribute servers"
  default     = ["eu-de-01", "eu-de-02"]
}

variable "otc_region" {
  type        = "string"
  description = "OTC requires region for DNS"
}

variable "otc_vpc" {
  type        = "string"
  description = "Open Telekom Cloud requires vpc_id for server creation"
  default     = ""
}

variable "otc_token" {
  type        = "string"
  description = "Open Telekom Cloud token for DNS registration workaround"
}
