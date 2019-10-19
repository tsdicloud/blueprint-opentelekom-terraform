resource "opentelekomcloud_networking_secgroup_v2" "sg_common" {
  name                 = "${var.sg_name}"
  description          = "Allow all inbound traffic"
  delete_default_rules = true

  // not relevant for OTC: vpc_id               = "${var.vpc_id}"
  // not relevant for OTC: region               = "${var.otc_region}"
  // TODO: OTC tags with new summer release?
  // tags {
  //  Name = "${var.sg_name}"
  // }
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "common_ssh_port" {
  direction         = "ingress"
  port_range_min    = 22
  port_range_max    = 22
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_mgmt}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_common.id}"

  // description = "SSH port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_external_ips" {
  direction         = "egress"
  protocol          = ""                                                        // ALL for protocol and ports
  ethertype         = "IPv4"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_common.id}"
  remote_ip_prefix  = "0.0.0.0/0"

  // description     = "Allowing All outbound destinations"
}

###
# additionally, add a rule for chef client to mgmt zone security group
# This step can only be done now because the remote secrity group is
# not known before this point.
# TODO: Introduce mgmt zone as parameter
data "opentelekomcloud_networking_secgroup_v2" "sg_mgmt" {
  name = "${var.tsys_sg_mgmt}"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "common_chef_port1" {
  direction         = "ingress"
  port_range_min    = 443
  port_range_max    = 443
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = "${opentelekomcloud_networking_secgroup_v2.sg_common.id}"
  security_group_id = "${data.opentelekomcloud_networking_secgroup_v2.sg_mgmt.id}"

  // description = "Chef https port"
}

###
# Workaround: Rules are not CONTAINED in security groups.
# On destroy, it could happen that the rules are destroyed before all
# servers are un-bootstrapped. Thus, we need an "artificial" dependency
# that embraces group and rule and that keeps them together until the end.
# Experiment: Use null_datasource to keep things together. 
#data "null_data_source" "keep_sg_common_rules" {
#  depends_on = ["opentelekomcloud_networking_secgroup_v2.sg_common",
#    "opentelekomcloud_networking_secgroup_rule_v2.common_ssh_port",
#    "opentelekomcloud_networking_secgroup_rule_v2.all_external_ips",
#  ]
#
#  inputs = {
#    id = "${opentelekomcloud_networking_secgroup_v2.sg_common.id}"
#  }
#}

