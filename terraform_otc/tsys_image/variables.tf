variable "image_name" {
  type        = "string"
  description = "Name of the image to create"
}

variable "image_version" {
  type        = "string"
  description = "Version string of the image"
}

variable "image_size" {
  type        = "string"
  description = "Size in GB"
}

variable "mgmt_vpc" {
  type        = "string"
  description = "Mgmt vpc to create images in"
}

variable "mgmt_subnet" {
  type        = "string"
  description = "Mgmt subnet to create images in"
}

variable "mgmt_security_groups" {
  type        = "list"
  description = "Mgmt security group to access image bakery server"
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

// --- OTC specific variables ---
variable "region" {
  type        = "string"
  description = "Open Telekom Cloud region"
  default     = "eu-de"
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
