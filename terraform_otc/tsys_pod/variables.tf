provider "opentelekomcloud" {
  region      = "${var.otc_region}"
  domain_name = "${var.otc_tenant}"
  tenant_name = "${var.otc_project}"
  user_name   = "${var.otc_user}"
  password    = "${var.otc_password}"
  auth_url    = "${var.otc_auth_url}"
  cacert_file = "${var.otc_cacert_file}"
  access_key  = "${var.otc_ak}"
  secret_key  = "${var.otc_sk}"
}

variable "mgmt_vpc" {
  type        = "string"
  description = "Mgmt vpc name to pair to"
}

variable "mgmt_chef_ip" {
  type        = "string"
  description = "IP for the chef server in mgmt (for DNS entry generation)"
}

variable "mgmt_consul_ip" {
  type        = "string"
  description = "IP for the consul server in mgmt (for DNS entry generation)"
}

variable "BUSINESSUNIT" {
  type        = "string"
  description = "Short id of the owning product unit"
  default     = "doaas"
}

variable "APPLICATIONENV" {
  type        = "string"
  description = "One of TSYST|PROD|QA|DEV|STAGING|OTHERS"
  default     = "staging"
}

variable "POD" {
  type        = "string"
  description = "Name of the ITERRA POD"
  default     = "pod1"
}

variable "otc_region" {
  type        = "string"
  description = "Open Telekom Cloud region"
  default     = "eu-de"
}

###
# Input variables from vpc.json
#
variable "cidr_blocks_mgmt" {
  type        = "string"
  description = "IP range of management zone"
  default     = "172.30.0.0/16"
}

variable "cidr_blocks_ma" {
  type        = "string"
  description = "IP range of ma"
}

variable "cidr_blocks_pod" {
  type        = "string"
  description = "IP range of pod access"
}

###
# --- OTC specific variables ---
#
variable "tsys_code_bucket_name" {
  type        = "string"
  description = "T-Systems ext: Name of the bucket to load cookbook packs to"
}

variable "tsys_code_localdir" {
  type        = "string"
  description = "T-Systems ext: Local dir to upload packages from"
}

variable "tsys_code_server" {
  type        = "string"
  description = "T-Systems ext: Base dns name of object store"
}

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
  default     = "../otc_certs.pem"
}

variable "otc_ak" {
  description = "Open Telekom Cloud keystone url (usually keep the default)"
  default     = ""
}

variable "otc_sk" {
  description = "Open Telekom Cloud root trust (usually keep th default)"
  default     = ""
}
