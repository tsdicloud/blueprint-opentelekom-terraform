variable "ec2_instance_id" {
  type = "string"
}

variable "elb_id" {
  type = "string"
}

// --- OTC specific variables ---
variable "otc_private_ips" {
  description = "Open Telekom Cloud needs list of private ips"
  type        = "list"
}
