variable "alias" {
  type = "string"
}

variable "deletion_window_in_days" {
  type    = "string"
  default = "30"
}

variable "description" {
  type = "string"
}

variable "key_usage" {
  type    = "string"
  default = "ENCRYPT_DECRYPT"
}

variable "is_enabled" {
  type    = "string"
  default = "true"
}

variable "enable_key_rotation" {
  type    = "string"
  default = "false"
}

variable "tags" {
  type = "map"
}
