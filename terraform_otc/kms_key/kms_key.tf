resource "opentelekomcloud_kms_key_v1" "create_kms_key" {
  key_alias       = "alias/${var.alias}"
  pending_days    = "${var.deletion_window_in_days}"
  key_description = "${var.description}"

  // TODO: make realm global parameter
  realm      = "doaas-1"
  is_enabled = "${var.is_enabled}"

  //TODO: tags    = "${merge(var.tags)}"
  //TODO: key_usage               = "${var.key_usage}"
  //TODO: enable_key_rotation     = "${var.enable_key_rotation}"
}
