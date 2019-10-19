// Provider specific configs
provider "opentelekomcloud" {
  region      = "${var.otc_region}"
  domain_name = "${var.otc_tenant}"
  tenant_name = "${var.otc_project}"
  user_name   = "${var.otc_user}"
  password    = "${var.otc_password}"
  auth_url    = "${var.otc_auth_url}"
  cacert_file = "${var.otc_cacert_file}"
}

variable "key_name" {
  type        = "string"
  description = "Name of the keypair on Open Telekom Cloud"
}

variable "user_key" {
  type        = "string"
  description = "Local filename of the (generated) private key file"
}

variable "ec2_user" {
  type        = "string"
  description = "User to login to remite server"
  default     = "linux"
}

variable "chef_env_name" {
  type = "string"
}

variable "chef_url" {
  type = "string"
}

variable "chef_user" {
  type = "string"
}

variable "chef_user_key" {
  type = "string"
}

variable "cidr_blocks_mgmt" {
  type        = "string"
  description = "IP range of management zone"
  default     = "172.30.0.0/16"
}

variable "cidr_blocks_cr" {
  type        = "string"
  description = "IP range of cr"
}

variable "cidr_blocks_ma" {
  type        = "string"
  description = "IP range of ma"
}

variable "cidr_blocks_pod" {
  type        = "string"
  description = "IP range of pod access"
}

variable "cidr_blocks_nagios" {
  type        = "string"
  description = "IP range of nagios monitoring"
}

variable "vpc_id" {
  type        = "string"
  description = "ID of the pods VPC"
}

variable "otc_dns_vpcs" {
  type        = "list"
  description = "list of vpcs where DNS entries should be made"
}

variable "subnets" {
  type        = "list"
  description = "List of subnets to spread servers over"
}

variable "security_group_ids" {
  type        = "list"
  description = "List of security groups to apply"
}

variable "otc_azs" {
  type        = "list"
  description = "AZS to spread services over"
  default     = ["eu-de-01", "eu-de-02"]
}

variable "db_security_group_ids" {
  type        = "list"
  description = "List of security groups to apply fo db"
}

variable "db_subnet" {
  type        = "string"
  description = "subnet for primary RDS DB"
}

variable "otc_region" {
  type        = "string"
  description = "Open Telekom Cloud region"
  default     = "eu-de"
}

variable "efs_ip_address" {
  type = "string"
}

// --- OTC specific variables ---
variable "otc_tenant" {
  description = "Open Telekom Cloud tenant = domain"
  default     = ""
}

variable "otc_project" {
  description = "Open Telekom Cloud project within tenant"
  default     = ""
}

variable "otc_user" {
  description = "Open Telekom Cloud api username"
  default     = "dooas_api"
}

variable "otc_password" {
  description = "Open Telekom Cloud api credentials"
  default     = ""
}

variable "otc_auth_url" {
  description = "Open Telekom Cloud keystone url (usually keep the default)"
  default     = "https://iam.eu-de.otc.t-systems.com/v3"
}

variable "otc_cacert_file" {
  description = "Open Telekom Cloud root trust (usually keep th default)"
  default     = "otc_certs.pem"
}
