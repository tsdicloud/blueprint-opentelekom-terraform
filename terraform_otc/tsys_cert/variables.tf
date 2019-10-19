###
# Required parameters
#
variable "ca_label" {
  type        = "string"
  description = "CN suffix the CA to use"
}

variable "base_dir" {
  type        = "string"
  description = "Path to topo dir"
}

variable "haproxies" {
  type        = "map"
  description = "Node dns name to services mapping for certifterrate distribution"
}

variable "num_haproxies" {
  type        = "string"
  description = "Number of haproxy nodes for planning phase"
}

variable "kafka" {
  type        = "map"
  description = "Node dns name to services mapping for certifterrate distribution"
}

variable "num_kafka" {
  type        = "string"
  description = "Number of kafka nodes for planning phase"
}

variable "saas" {
  type        = "map"
  description = "Node dns name to services mapping for certifterrate distribution"
}

variable "num_saas" {
  type        = "string"
  description = "Number of saas nodes for planning phase"
}

variable "services" {
  type        = "map"
  description = "Node dns name to services mapping for certifterrate distribution"
}

variable "num_services" {
  type        = "string"
  description = "Number of service nodes for planning phase"
}

variable "service_certs" {
  type        = "string"
  description = "false if no service vertificates should be generated (default true)"
  default     = "true"
}

#variable "service_user" {
#  type        = "string"
#  description = "Name of the unix user to assign the certificates to"
#}

variable "key_password" {
  type        = "string"
  description = "Password for the Java keystore"
}

variable "trust_password" {
  type        = "string"
  description = "Password for the Truststore"
}

variable "root_cert_dir" {
  type        = "string"
  description = "Path for keys and certificates on server"
}

variable "ec2_user" {
  type        = "string"
  description = "SSH user to access the infra servers"
}

variable "user_key" {
  type        = "string"
  description = "SSH key for SSH user"
}

###
# Optional (static) parameters.
# May change defaults for different target platforms"
variable "ca_basename" {
  type        = "string"
  description = "General basename for all CA in this context"
  default     = "T-Systems DOaaS Test CA"
}

variable "root_type" {
  type        = "string"
  description = "Key type and strength to generate - root ca"
  default     = "rsa:4096"
}

variable "root_days" {
  type        = "string"
  description = "Expiration period in days - root - root ca"
  default     = "3650"
}

variable "inter_type" {
  type        = "string"
  description = "Key type and strength to generate - intermediate ca"
  default     = "rsa:4096"
}

variable "inter_days" {
  type        = "string"
  description = "Expiration period in days - intermediate ca"
  default     = "1825"
}

variable "key_type" {
  type        = "string"
  description = "Key type and strength to generate - host-service key"
  default     = "rsa:4096"
}

variable "key_days" {
  type        = "string"
  description = "Expiration period in days - host-service key"
  default     = "1095"
}
