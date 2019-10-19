resource "opentelekomcloud_networking_secgroup_v2" "sg_db" {
  name                 = "${var.sg_name}"
  description          = "Traffic control for DB zone"
  delete_default_rules = true

  // not relevant for OTC: vpc_id               = "${var.vpc_id}"
  // not relevant for OTC: region               = "${var.otc_region}"
  // TODO: OTC tags with new summer release?
  // tags {
  //  Name = "${var.sg_name}"
  // }

  lifecycle {
    ignore_changes = ["delete_default_rules"]
  }
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "cross_region_cr" {
  direction         = "ingress"
  port_range_min    = 3306
  port_range_max    = 3306
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_cr}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_db.id}"

  // description = "Cross-region CIDR Blocks"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "cross_region_pod" {
  direction         = "ingress"
  port_range_min    = 3306
  port_range_max    = 3306
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_db.id}"

  // description = "Cross-region CIDR Blocks"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "cross_region_ma" {
  count             = "${ var.cidr_blocks_pod == var.cidr_blocks_ma ? 0 : 1}"
  direction         = "ingress"
  port_range_min    = 3306
  port_range_max    = 3306
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_ma}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_db.id}"

  // description = "Cross-region CIDR Blocks"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_external_ips" {
  direction         = "egress"
  protocol          = ""                                                    // ALL for protocol and ports
  ethertype         = "IPv4"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_db.id}"
  remote_ip_prefix  = "0.0.0.0/0"

  // description     = "Allowing All outbound destinations"
}
