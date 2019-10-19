variable "dns_zone_name" {
  type        = "string"
  description = "The DNS zone suffix"
}

variable "names" {
  type        = "list"
  description = "(Multiple) names that to enter"
}

variable "ips" {
  type        = "list"
  description = "(Multiple) ips that the name resolves to. If more ips than names, the ips are distributed evenly among the names"
}

variable "num_entries" {
  type        = "string"
  description = "Count for ressource calls; terraform needs the size of lists at plan time, although list content that is the output of other calls is not available. It is although helpful if disabling the module during a run is required."
  default     = "1"
}

// --- OTC specific variables ---
variable "otc_zone_type" {
  type        = "string"
  description = " 'private' or 'public' zone entry"
  default     = "private"
}

variable "otc_region" {
  type        = "string"
  description = "OTC requires region for ELB generation"
}

variable "otc_dns_vpcs" {
  type        = "list"
  description = "OTC requires VPC list for private zone creation, non derivable"
}

variable "otc_token" {
  type        = "string"
  description = "Open Telekom Cloud token for DNS registration workaround"
}
