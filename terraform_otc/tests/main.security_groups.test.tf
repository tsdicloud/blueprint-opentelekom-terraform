module "create_sg_common" {
  source = "../security_group/sg_common"

  cidr_blocks_mgmt = "${var.cidr_blocks_mgmt}"
  sg_name          = "SG-doaas-test-pod1-COMMON"
  vpc_id           = "${var.vpc_id}"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}

module "create_sg_db" {
  source = "../security_group/sg_db"

  // TODO: verify CIDR ranges (they do not map intuitively to subnets)
  cidr_blocks_cr  = "${var.cidr_blocks_cr}"
  cidr_blocks_ma  = "${var.cidr_blocks_ma}"
  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "SG-doaas-test-pod1-DB"
  vpc_id          = "${var.vpc_id}"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}

module "create_sg_app" {
  source = "../security_group/sg_app"

  // TODO: verify CIDR ranges (they do not map intuitively to subnets)
  cidr_blocks_ma  = "${var.cidr_blocks_ma}"
  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "SG-doaas-test-pod1-APP"
  vpc_id          = "${var.vpc_id}"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}

module "create_sg_efs" {
  source = "../security_group/sg_efs"

  // TODO: verify CIDR ranges (they do not map intuitively to subnets)
  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "SG-doaas-test-pod1-EFS"
  vpc_id          = "${var.vpc_id}"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}

module "create_sg_elb" {
  source = "../security_group/sg_elb"

  // TODO: verify CIDR ranges (they do not map intuitively to subnets)
  sg_name = "SG-doaas-test-pod1-ELB"
  vpc_id  = "${var.vpc_id}"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}

module "create_sg_monitor" {
  source = "../security_group/sg_monitor"

  // TODO: verify CIDR ranges (they do not map intuitively to subnets)
  cidr_blocks_ma     = "${var.cidr_blocks_ma}"
  cidr_blocks_pod    = "${var.cidr_blocks_pod}"
  cidr_blocks_nagios = "${var.cidr_blocks_nagios}"
  sg_name            = "SG-doaas-test-pod1-MONITOR"
  vpc_id             = "${var.vpc_id}"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}

module "create_sg_web" {
  source = "../security_group/sg_web"

  // TODO: verify CIDR ranges (they do not map intuitively to subnets)
  cidr_blocks_ma  = "${var.cidr_blocks_ma}"
  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "SG-doaas-test-pod1-WEB"
  vpc_id          = "${var.vpc_id}"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}
