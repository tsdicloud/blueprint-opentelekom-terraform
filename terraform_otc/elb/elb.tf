locals {
  # remove protocol part e.g. https:// if any for the record entry name
  # the remaining part after the first . is the zone name
  record_pattern = "/[^:]+:\\/\\//"

  record_name  = "${replace(var.dns_name, local.record_pattern, "") }"
  zone_pattern = "/([^\\.]+)\\.(.+)/"
  entry_name   = "${replace(local.record_name, local.zone_pattern, "$1")}"
  zone_name    = "${replace(local.record_name, local.zone_pattern, "$2")}"
}

resource "opentelekomcloud_elb_loadbalancer" "elb_int" {
  count = "${var.elb_is_internal == "true" ? var.number_of_instances : 0}"

  name = "${var.name}"
  type = "Internal"

  // TODO: no cross-zone loadbalancing for internal loadbalancers yer
  // (at least not with multiple subnets). Maybe better with true ULB
  // later this year
  vip_subnet_id = "${var.subnets[count.index]}"

  vpc_id            = "${var.otc_vpc}"
  security_group_id = "${var.elb_security_group}"

  // cross-zone loadbalancing for internal LB are the default
  // you can make them local with an AZ specifying az = ...

  // TODO: tags are missing for load balancers yet in OTC provider
  // tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "opentelekomcloud_elb_loadbalancer" "elb_ext" {
  count = "${var.elb_is_internal == "false" ? var.number_of_instances : 0}"

  name      = "${var.name}"
  type      = "External"
  bandwidth = 300
  vpc_id    = "${var.otc_vpc}"

  // TODO: tags are missing for load balancers yet in OTC provider
  // tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

locals {
  elb_ids   = "${compact(concat(opentelekomcloud_elb_loadbalancer.elb_ext.*.id, opentelekomcloud_elb_loadbalancer.elb_int.*.id))}"
  elb_names = "${compact(concat(opentelekomcloud_elb_loadbalancer.elb_ext.*.name, opentelekomcloud_elb_loadbalancer.elb_int.*.name))}"
  elb_vips  = "${compact(concat(opentelekomcloud_elb_loadbalancer.elb_ext.*.vip_address, opentelekomcloud_elb_loadbalancer.elb_int.*.vip_address))}"
}

resource "opentelekomcloud_elb_listener" "otc-listener" {
  count            = "${var.number_of_instances}"
  name             = "${format("%s-%d", var.name, count.index+1)}"
  protocol         = "${var.lb_protocol}"
  protocol_port    = "${var.lb_port}"
  backend_protocol = "${var.backend_protocol}"
  backend_port     = "${var.lb_port}"
  lb_algorithm     = "roundrobin"
  certificate_id   = "${var.ssl_certificate_id}"

  // TODO: OTC security parameter: ssl_protocols = "TLSv1.2"
  // TODO: OTC security parameter: ssl_ciphers   = "???"
  loadbalancer_id = "${local.elb_ids[count.index]}"

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }

  // TODO: only for otc elb application type: 
  // idle_timeout              = "${var.idle_timeout}"
}

resource "opentelekomcloud_elb_health" "otc-health" {
  count                    = "${var.number_of_instances}"
  listener_id              = "${opentelekomcloud_elb_listener.otc-listener.*.id[count.index]}"
  healthcheck_protocol     = "${element(split(":", var.health_check_target), 0)}"
  healthcheck_connect_port = "${element(split(":", var.health_check_target), 1)}"
  healthy_threshold        = 2                                                                 // original ITERRA
  unhealthy_threshold      = 2                                                                 // original ITERRA
  healthcheck_timeout      = 3                                                                 // original ITERRA
  healthcheck_interval     = 5                                                                 // original ITERRA:30, OTC between 1 and 5

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

locals {
  num_ecs = "${length(var.instances)}"
}

resource "opentelekomcloud_elb_backend" "backend" {
  count       = "${ var.number_of_instances >0 ? var.num_backends : 0 }"
  listener_id = "${opentelekomcloud_elb_listener.otc-listener.*.id[count.index % var.number_of_instances]}"
  address     = "${var.otc_backend_ips[count.index]}"
  server_id   = "${var.instances[count.index]}"
}

#
# all elb will have the same DNS and distribute traffic by DNS
#
module "create-elb-dns" {
  source = "../route53_record"

  num_entries   = "${(var.number_of_instances>0 && var.dns_name != "") ? 1 : 0}"
  dns_zone_name = "${local.zone_name}"
  names         = ["${local.entry_name}"]
  ips           = ["${local.elb_vips}"]

  otc_region    = "${var.otc_region}"
  otc_zone_type = "${var.elb_is_internal == "true" ? "private" : "public" }"
  otc_dns_vpcs  = ["${var.otc_vpc}"]
  otc_token     = "${var.otc_token}"
}
