resource "opentelekomcloud_networking_secgroup_v2" "sg_web" {
  name        = "${var.sg_name}"
  description = "Allow all inbound traffic"

  //region               = "${var.otc_region}"
  delete_default_rules = true

  // not relevant for OTC: vpc_id               = "${var.vpc_id}"
  // TODO: OTC tags with new summer release?
  // tags {
  //  Name = "${var.sg_name}"
  // }
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "https_port_1" {
  direction         = "ingress"
  port_range_min    = 443
  port_range_max    = 443
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_ma}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_web.id}"

  // description = "HTTPS Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "https_port_2" {
  count             = "${ var.cidr_blocks_pod == var.cidr_blocks_ma ? 0 : 1}"
  direction         = "ingress"
  port_range_min    = 443
  port_range_max    = 443
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_web.id}"

  // description = "HTTPS Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "https_port_3" {
  direction         = "ingress"
  port_range_min    = 443
  port_range_max    = 443
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = "${opentelekomcloud_networking_secgroup_v2.sg_web.id}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_web.id}"

  // description = "HTTPS Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_external_ips" {
  direction         = "egress"
  protocol          = ""                                                     // ALL for protocol and ports
  ethertype         = "IPv4"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_web.id}"
  remote_ip_prefix  = "0.0.0.0/0"

  // description     = "Allowing All outbound destinations"
}
