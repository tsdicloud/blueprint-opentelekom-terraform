// Provider specific configs
provider "opentelekomcloud" {
  # region      = "${var.otc_region}"
  domain_name = "${var.otc_tenant}"
  tenant_name = "${var.otc_project}"
  user_name   = "${var.otc_user}"
  password    = "${var.otc_password}"
  auth_url    = "${var.otc_auth_url}"
  cacert_file = "${var.otc_cacert_file}"
}

resource "opentelekomcloud_elb_backend" "backend" {
  address     = ["${var.otc_private_ips[count]}"]
  listener_id = "${var.elb_id}"
  server_id   = "${var.instances[count]}"
}
