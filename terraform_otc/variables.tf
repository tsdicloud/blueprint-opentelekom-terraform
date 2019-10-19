###
# Main variable to reference the topo.json as external data source
#
variable "topo_file" {
  type        = "string"
  description = "Path to the topology specification file as data source"
  default     = "topo.json"
}

###
# Input variables from vpc.json
#
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

variable "CONSUL" {
  type        = "string"
  description = "URL to reach CONSUL mgmt server (for HAProxy configuration)"
}

variable "subnet_app_za" {
  type        = "string"
  description = "Application subnet, AZ A"
}

variable "subnet_app_zb" {
  type        = "string"
  description = "Application subnet, AZ B"
}

variable "subnet_db_za" {
  type        = "string"
  description = "Database subnet, AZ A"
}

variable "subnet_db_zb" {
  type        = "string"
  description = "Database subnet, AZ B"
}

variable "subnet_public_za" {
  type        = "string"
  description = "Public subnet, AZ A"
}

variable "subnet_public_zb" {
  type        = "string"
  description = "Public subnet, AZ B"
}

variable "subnet_web_za" {
  type        = "string"
  description = "Web subnet, AZ A"
}

variable "subnet_web_zb" {
  type        = "string"
  description = "Web subnet, AZ B"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC for pod installation"
}

###
# Common input variables from pod.json
#
variable "ami_id" {
  type        = "map"
  description = "Map of base images (depending on RedHat version)"
}

variable "otc_region" {
  type        = "string"
  description = "Cloud region to install pod in"
}

variable "chef_repo_dir" {
  description = "Knife only works on local chef server if call from repo-dir"
}

variable "chef_user_key" {}

#variable "chef_repo_dir" {
#  type        = "string"
#  description = "Path to repo dir (on local management machine)"
#}

variable "chef_user" {
  type        = "string"
  description = "TODO: Chef user into wallet"
  default     = ""
}

variable "chef_server_url" {
  type        = "string"
  description = "Fully qualified name of chef server matching ssl certificate."
}

variable "ebs_device_name" {
  type        = "string"
  description = "Mount device for data volume server (may even obsolete for AWS?)"
  default     = ""
}

variable "ebs_root_volume_size" {
  type        = "string"
  description = "System 'root' volume size for servers."
  default     = "30"
}

variable "ebs_root_volume_type" {
  type        = "string"
  description = "System 'root' volume type for servers."
  default     = "standard"
}

variable "ebs_root_volume_iops" {
  type        = "string"
  description = "System 'root' volume iops for servers."
  default     = "0"
}

variable "ebs_volume_type" {
  type        = "string"
  description = "Data volume type for servers."
  default     = "standard"
}

variable "ebs_volume_iops" {
  type        = "string"
  description = "Data volume iops for servers."
  default     = "0"
}

variable "enable_encrypted_ebs" {
  type        = "string"
  description = "true to encrypt daat volumes of servers"
}

variable "key_name" {
  type        = "string"
  description = "Name of SSH key in cloud."
}

variable "latest_ami" {
  type        = "string"
  description = "Boolean to indicate whether to use the latest ami or a fixed one."
}

variable "ma_url" {
  type        = "string"
  description = "URL to access MA pod"
  default     = ""
}

variable "pod_url" {
  type        = "string"
  description = "URL to access pod itself"
}

variable "user_key" {
  type        = "string"
  description = "Local path on mgmt server to ssh key for cloud server login"
  default     = ""
}

variable "ALERTGROUP" {
  type        = "string"
  description = "Tag for alert group"
}

variable "APPLICATIONENV" {
  type        = "string"
  description = "Tag for environment type: One of PROD|QA|DEV|STAGING|OTHERS"
}

variable "BUSINESSUNIT" {
  type        = "string"
  description = "Tag for business unit. 'DOaaS' for T-Systems"
}

variable "DOMAIN" {
  type        = "string"
  description = "Tag for ITERRA internet domain name"
}

variable "INTERNALPROXY" {
  type        = "string"
  description = "Tag for internal proxy usage ON|OFF"
}

variable "OWNEREMAIL" {
  type        = "string"
  description = "Tag for email of pod owner"
}

variable "POD" {
  type        = "string"
  description = "Tag for for pod name (used in cloud queries)"
}

variable "RUNNINGSCHEDULE" {
  type        = "string"
  description = "Schedule time tag"
}

variable "root_cert_dir" {
  type        = "string"
  description = "Server path to certificate directory"
}

variable "haproxy_key" {
  type        = "string"
  description = "External key/certfile name"
}

###
# Vars for T-Systems extensions in pod.json
variable "tsys_code_bucket_name" {
  type        = "string"
  description = "T-Systems ext: Name of the bucket to load cookbook packs to"
}

variable "tsys_code_localdir" {
  type        = "string"
  description = "T-Systems ext: Local dir to upload packages from"
}

variable "tsys_package_url" {
  type        = "string"
  description = "T-Systems ext: Base url of code store"
}

variable "tsys_key_password" {
  type        = "string"
  description = "T-Systems ext: keystore password to use"
}

variable "tsys_trust_password" {
  type        = "string"
  description = "T-Systems ext: truststore password to use"
}

###
# Dedicated input variables for OTC from vpc.json
variable "otc_azs" {
  type        = "list"
  description = "Open Telekom Cloud, azs to distribute resources betwenn"
}

###
# Dedicated input variables for OTC from pod.json
#
variable "otc_tenant" {
  type        = "string"
  description = "Open Telekom Cloud tenant = domain"
}

variable "otc_project" {
  type        = "string"
  description = "Open Telekom Cloud project within tenant"
}

variable "otc_user" {
  type        = "string"
  description = "Open Telekom Cloud api username"
}

variable "otc_password" {
  type        = "string"
  description = "Open Telekom Cloud api credentials"
}

variable "otc_auth_url" {
  type        = "string"
  description = "Open Telekom Cloud keystone url (usually keep the default)"
  default     = "https://iam.eu-de.otc.t-systems.com/v3"
}

variable "otc_cacert_file" {
  type        = "string"
  description = "Open Telekom Cloud root trust (usually keep th default)"
  default     = "./otc_certs.pem"
}

variable "otc_ak" {
  description = "Open Telekom Cloud keystone url (usually keep the default)"
  default     = ""
}

variable "otc_sk" {
  description = "Open Telekom Cloud root trust (usually keep th default)"
  default     = ""
}
