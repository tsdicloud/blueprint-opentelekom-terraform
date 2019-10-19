resource "opentelekomcloud_networking_secgroup_v2" "sg_monitor" {
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

resource "opentelekomcloud_networking_secgroup_rule_v2" "nagios_mysql_port" {
  direction         = "ingress"
  port_range_min    = 3306
  port_range_max    = 3306
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_nagios}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_monitor.id}"

  // description = "Nagios MySQL Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "nagios_server_port" {
  direction         = "ingress"
  port_range_min    = 5666
  port_range_max    = 5666
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_nagios}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_monitor.id}"

  // description = "Nagios Server Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "consul_tcp_port_1" {
  direction         = "ingress"
  port_range_min    = 8301
  port_range_max    = 8301
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_monitor.id}"

  // description = "Consul TCP Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "consul_tcp_port_2" {
  count             = "${ var.cidr_blocks_pod == var.cidr_blocks_ma ? 0 : 1}"
  direction         = "ingress"
  port_range_min    = 8301
  port_range_max    = 8301
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_ma}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_monitor.id}"

  // description = "Consul TCP Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "consul_udp_port_1" {
  direction         = "ingress"
  port_range_min    = 8301
  port_range_max    = 8301
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_monitor.id}"

  // description = "Consul UDP Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "consul_udp_port_2" {
  count             = "${ var.cidr_blocks_pod == var.cidr_blocks_ma ? 0 : 1}"
  direction         = "ingress"
  port_range_min    = 8301
  port_range_max    = 8301
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_ip_prefix  = "${var.cidr_blocks_ma}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_monitor.id}"

  // description = "Consul UDP Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_external_ips" {
  direction         = "egress"
  protocol          = ""                                                         // ALL for protocol and ports
  ethertype         = "IPv4"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_monitor.id}"
  remote_ip_prefix  = "0.0.0.0/0"

  // description     = "Allowing All outbound destinations"
}
