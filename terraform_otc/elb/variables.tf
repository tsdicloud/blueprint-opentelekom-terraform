//
// Module: tf_otc_elb/elb_https
//

// Module specific variables

variable "name" {}

variable "lb_port" {}

variable "lb_protocol" {}

variable "idle_timeout" {
  default = "60"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
}

variable "elb_is_internal" {
  description = "Determines if the ELB is internal or not"
  default     = false

  // Defaults to false, which results in an external IP for the ELB
}

variable "elb_security_group" {}

// See README.md for details on finding the
// ARN of an SSL certificate in EC2
variable "ssl_certificate_id" {
  description = "The ARN of the SSL Certificate in EC2"
  default     = ""
}

variable "subnets" {
  type = "list"
}

variable "backend_port" {
  description = "The port the service on the EC2 instances listens on"
}

variable "backend_protocol" {
  description = "The protocol the backend service speaks"

  // Possible options are
  // - http
  // - https
  // - tcp
  // - ssl (secure tcp)
}

variable "health_check_target" {
  description = "The URL the ELB should use for health checks"

  // This is primarily used with `http` or `https` backend protocols
  // The format is like `HTTP:443/health` or `HTTPS:443/health` or `TCP:PORT`
}

variable "instances" {
  type = "list"
}

variable "accept_proxy" {
  type    = "string"
  default = "false"
}

variable "number_of_instances" {
  type        = "string"
  description = "Variable required to enable/disable a module"
  default     = "1"
}

variable "num_backends" {
  type        = "string"
  description = "Terraform requires size of count on plan stage. The variable can also be used ti disable call."
  default     = 1
}

###
# OTC specific variables
variable "dns_name" {
  type        = "string"
  description = "Dns name to create for loadbalancer on create"
  default     = ""
}

variable "otc_vpc" {
  type = "string"
}

variable "otc_region" {
  type        = "string"
  description = "Region required for DNS entry"
}

variable "otc_backend_ips" {
  type        = "list"
  description = "List of private IP addresses to balance between"
  default     = []
}

variable "otc_token" {
  type        = "string"
  description = "Open Telekom Cloud token for DNS registration workaround"
}
