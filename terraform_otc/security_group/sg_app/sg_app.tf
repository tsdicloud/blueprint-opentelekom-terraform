resource "opentelekomcloud_networking_secgroup_v2" "sg_app" {
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

resource "opentelekomcloud_networking_secgroup_rule_v2" "kafka_port2" {
  direction         = "ingress"
  port_range_min    = 2181
  port_range_max    = 2181
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Another Kafka Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "zookeeper_port" {
  direction         = "ingress"
  port_range_min    = 2888
  port_range_max    = 3888
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Zookeeper Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "saas_jsf_port" {
  direction         = "ingress"
  port_range_min    = 9012
  port_range_max    = 9012
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  //  description = "SaaS JSF Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "kafka_port1_pod" {
  direction         = "ingress"
  port_range_min    = 9089
  port_range_max    = 9092
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Kafka Ports"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "kafka_port1_ma" {
  count             = "${ var.cidr_blocks_pod == var.cidr_blocks_ma ? 0 : 1}"
  direction         = "ingress"
  port_range_min    = 9089
  port_range_max    = 9092
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_ma}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Kafka Ports"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "microservices_port1_pod" {
  direction         = "ingress"
  port_range_min    = 16000
  port_range_max    = 16150
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Micro Services Ports"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "microservices_port1_ma" {
  count             = "${ var.cidr_blocks_pod == var.cidr_blocks_ma ? 0 : 1}"
  direction         = "ingress"
  port_range_min    = 16000
  port_range_max    = 16150
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_ma}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Micro Services Ports"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "auditlog_port" {
  direction         = "ingress"
  port_range_min    = 16529
  port_range_max    = 16529
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Auditlog-service Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "autoscaler_service_port" {
  direction         = "ingress"
  port_range_min    = 16629
  port_range_max    = 16629
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "Autoscaler-service Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "mftsaas_port" {
  direction         = "ingress"
  port_range_min    = 18055
  port_range_max    = 18055
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "MFTSaaS Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "cci_port1_pod" {
  direction         = "ingress"
  port_range_min    = 20023
  port_range_max    = 20023
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_pod}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "CCI Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "cci_port1_ma" {
  count             = "${ var.cidr_blocks_pod == var.cidr_blocks_ma ? 0 : 1}"
  direction         = "ingress"
  port_range_min    = 20023
  port_range_max    = 20023
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "${var.cidr_blocks_ma}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description = "CCI Port"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "group_internal_all" {
  direction         = "ingress"
  protocol          = ""
  ethertype         = "IPv4"
  remote_group_id   = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"

  // description     = "Allowing All Traffic from Same Security Group"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_external_ips" {
  direction         = "egress"
  protocol          = ""                                                     // ALL for protocol and ports
  ethertype         = "IPv4"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"
  remote_ip_prefix  = "0.0.0.0/0"

  // description     = "Allowing All outbound destinations"
}
