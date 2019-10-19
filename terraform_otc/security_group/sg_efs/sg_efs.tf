resource "opentelekomcloud_networking_secgroup_v2" "sg_efs" {
  name                 = "${var.sg_name}"
  description          = "Allow all inbound traffic"
  delete_default_rules = true

  //region               = "${var.otc_region}"
  // not relevant for OTC: vpc_id               = "${var.vpc_id}"
  // TODO: OTC tags with new summer release?
  // tags {
  //  Name = "${var.sg_name}"
  // }
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "efs_port" {
  direction         = "ingress"
  port_range_min    = 2049
  port_range_max    = 2049
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_efs.id}"

  // description = "TERRA efs port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_external_ips" {
  direction         = "egress"
  protocol          = ""                                                     // ALL for protocol and ports
  ethertype         = "IPv4"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_efs.id}"
  remote_ip_prefix  = "0.0.0.0/0"

  // description     = "Allowing All outbound destinations"
}
