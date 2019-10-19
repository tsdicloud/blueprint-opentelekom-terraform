// Dependency
terraform {
  required_version = "> 0.11.6"
}

data "external" "topo" {
  # Select the section of the primary service and make it a flat list of 
  # strings
  program = ["jq", "[.[]|select(.tf_type==\"elb\")|select( .contents[]|contains(\"${var.main_service}\"))|.contents|=join(\",\")|.[]|=if type==\"number\" then tostring else . end]+[{}]|.[0]", "${var.topo_file}"]
}

locals {
  # enable or disable 
  number_of_instances = "${lookup(data.external.topo.result, "count", 0) }"

  # detect existence of data in locals
  contents        = "${lookup(data.external.topo.result, "contents", "")}"
  run_list        = "${split(",", local.contents)}"
  APPLICATIONROLE = "${lookup(data.external.topo.result, "APPLICATIONROLE", var.tags["APPLICATIONROLE"])}"
}

module "create-topo-elb" {
  source = "../elb"

  number_of_instances = "${local.number_of_instances}"

  name                = "${var.name}"
  dns_name            = "${var.dns_name}"
  lb_port             = "${var.lb_port}"
  lb_protocol         = "${var.lb_protocol}"
  idle_timeout        = "${var.idle_timeout}"
  elb_is_internal     = "${var.elb_is_internal}"
  elb_security_group  = "${var.elb_security_group}"
  ssl_certificate_id  = "${var.ssl_certificate_id}"
  subnets             = ["${var.subnets}"]
  backend_port        = "${var.backend_port}"
  backend_protocol    = "${var.backend_protocol}"
  health_check_target = "${var.health_check_target}"
  accept_proxy        = "${var.accept_proxy}"
  instances           = "${var.instances}"

  otc_vpc         = "${var.otc_vpc}"
  otc_region      = "${var.otc_region}"
  otc_backend_ips = "${var.otc_backend_ips}"
  otc_token       = "${var.otc_token}"

  // NAME, Name and SHORT_HOSTNAME will be generated at runtime
  tags = "${merge(var.tags, 
                  map("APPLICATIONROLE", local.APPLICATIONROLE))}"
}
