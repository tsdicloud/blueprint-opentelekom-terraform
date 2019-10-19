##
# Stage 1: VPC, subnets analog to AWS
#
locals {
  podprefix = "${lower(var.BUSINESSUNIT)}-${lower(var.APPLICATIONENV)}-${lower(var.POD)}"
}

resource "opentelekomcloud_vpc_v1" "iterra_pod_vpc" {
  name = "${local.podprefix}-vpc"
  cidr = "10.33.0.0/16"

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_app_za" {
  availability_zone = "eu-de-01"
  name              = "sn-${local.podprefix}-app-za"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.0.0/20"
  gateway_ip        = "10.33.0.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_app_zb" {
  availability_zone = "eu-de-02"
  name              = "sn-${local.podprefix}-app-zb"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.32.0/20"
  gateway_ip        = "10.33.32.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_db_za" {
  availability_zone = "eu-de-01"
  name              = "sn-${local.podprefix}-db-za"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.64.0/20"
  gateway_ip        = "10.33.64.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_db_zb" {
  availability_zone = "eu-de-02"
  name              = "sn-${local.podprefix}-db-zb"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.96.0/20"
  gateway_ip        = "10.33.96.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_public_za" {
  availability_zone = "eu-de-01"
  name              = "sn-${local.podprefix}-public-za"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.128.0/20"
  gateway_ip        = "10.33.128.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_public_zb" {
  availability_zone = "eu-de-02"
  name              = "sn-${local.podprefix}-public-zb"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.160.0/20"
  gateway_ip        = "10.33.160.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_web_za" {
  availability_zone = "eu-de-01"
  name              = "sn-${local.podprefix}-web-za"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.192.0/20"
  gateway_ip        = "10.33.192.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_web_zb" {
  availability_zone = "eu-de-02"
  name              = "sn-${local.podprefix}-web-zb"
  vpc_id            = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  cidr              = "10.33.224.0/20"
  gateway_ip        = "10.33.224.1"
  dns_list          = ["100.125.4.25", "8.8.8.8"]

  lifecycle {
    prevent_destroy = "true"
  }
}

##
# Stage 2: Peering with mgmt zone
#
data "opentelekomcloud_vpc_v1" "mgmt_vpc" {
  name = "${var.mgmt_vpc}"
}

resource "opentelekomcloud_vpc_peering_connection_v2" "peer_to_mgmt" {
  name        = "peering-${local.podprefix}-to-mgmt"
  vpc_id      = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  peer_vpc_id = "${data.opentelekomcloud_vpc_v1.mgmt_vpc.id}"
}

resource "opentelekomcloud_vpc_route_v2" "peer_route_1" {
  type        = "peering"
  vpc_id      = "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"
  destination = "172.30.0.0/16"
  nexthop     = "${opentelekomcloud_vpc_peering_connection_v2.peer_to_mgmt.id}"
}

resource "opentelekomcloud_vpc_route_v2" "peer_route_2" {
  type        = "peering"
  vpc_id      = "${data.opentelekomcloud_vpc_v1.mgmt_vpc.id}"
  destination = "10.33.0.0/16"
  nexthop     = "${opentelekomcloud_vpc_peering_connection_v2.peer_to_mgmt.id}"
}

###
# Stage 3: Add internal DNS entries for Chef, TODO: Consul, ...
# At the moment, we use the IP of
# Helpful if standard provisioner is used, but skipped yet for
# direct node registration on chef server
module "create_chef_dns" {
  source = "../route53_record"

  ips      = ["${var.mgmt_chef_ip}"]
  dns_name = "chef.internal.doaas"

  // internal zones are scoped for dedicated VPCs. do not forget to add DNS
  // entries for management vpc!
  otc_region = "${var.otc_region}"

  otc_dns_vpcs = ["data.opentelekomcloud_vpc_v1.mgmt_vpc.id", "${opentelekomcloud_vpc_v1.iterra_pod_vpc.id}"]
}
