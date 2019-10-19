###
# Common input variables from pod.json
#
variable "chef_user_key" {}

variable "chef_repo_dir" {
  type        = "string"
  description = "Path to repo dir (on local management machine)"
}

variable "chef_user" {
  type        = "string"
  description = "TODO: Chef user into wallet"
  default     = ""
}

variable "chef_server_url" {
  type        = "string"
  description = "Fully qualified name of chef server matching ssl certificate."
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

variable "POD" {
  type        = "string"
  description = "Tag for for pod name (used in cloud queries)"
}

variable "root_cert_dir" {
  type        = "string"
  description = "Server path to certificate directory"
}

variable "haproxy_key" {
  type        = "string"
  description = "External key/certfile name"
}

variable "int_haproxy_key" {
  type        = "string"
  description = "Internal key/certfile name"
}

variable "podprefix" {
  type        = "string"
  description = "unique pod identifier"
}

variable "ipfilter" {
  type        = "string"
  description = ""
}

variable "package_url" {
  type        = "string"
  description = "Base url of code store"
}

variable "cdnURL" {
  type        = "string"
  description = ""
}

###
# Vars for T-Systems extensions in pod.json
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
