module "create-elb-doaas-test" {
  source = "../elb"

  name         = "doaas-elb-dummy"
  lb_port      = "80"
  lb_protocol  = "TCP"
  idle_timeout = "120"

  elb_is_internal = "true"

  elb_security_group  = "d6085834-255e-4e43-ba74-c7291e3ed309"                                           // needs id
  subnets             = ["145cc1f3-3d5c-4777-b7bd-1e88db703004", "f8191f94-cbc8-446e-b823-6b65ba62d044"]
  backend_port        = "8080"
  backend_protocol    = "TCP"
  health_check_target = "TCP:8080"

  instances    = [""]
  accept_proxy = false

  otc_vpc = "${var.vpc_id}"

  tags {
    ALERTGROUP      = "iterra_team"
    APPLICATIONENV  = "QA"
    APPLICATIONROLE = "RDS"
    BUSINESSUNIT    = "ITERRA"
    DOMAIN          = "infacloudops.net"
    OWNEREMAIL      = "rg@terra.com"
    RUNNINGSCHEDULE = "00:00:23:59:1-7"
  }
}
