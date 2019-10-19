variable "mgmt_key_name" {
  type        = "string"
  description = "Mgmt key ssh"
}

variable "mgmt_user_key" {
  type        = "string"
  description = "Pathname of magmt key file"
}

variable "mgmt_vpc_name" {
  type        = "string"
  description = "Vpc name of mgmt zone"
}

variable "mgmt_subnet_jump" {
  type        = "string"
  description = "Name of the subnet containing jumpservers"
  default     = "sn-doaas-jump"
}

variable "chef_user" {
  type        = "string"
  description = "Chef server user name"
}

variable "chef_password" {
  type        = "string"
  description = "Chef server password"
}

variable "chef_longname" {
  type        = "string"
  description = "firstname lastname of user"
}

variable "chef_email" {
  type        = "string"
  description = "Emaiil address of chef server user"
}

variable "chef_keyfile" {
  type        = "string"
  description = "Generated chef RSA key for chef user"
}

variable "chef_env_name" {
  type        = "string"
  description = "Chef organisation mnemonic"
}

variable "chef_longorg" {
  type        = "string"
  description = "Long organsiation name (with spaces)"
}

variable "ec2_user" {
  type        = "string"
  description = "Login user to mgmt jumpserver"
}

variable "otc_region" {
  type        = "string"
  description = "Open Telekom Cloud region"
  default     = "eu-de"
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
  default     = "../otc_certs.pem"
}
