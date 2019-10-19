# Python lacks proper dependency tracking, see:code comment
# TODO: Validate prerequisites (Security Group)

# DB parameter groups not used in AWS

# TODO: Validate prerequisites (KMS Key, Security Group)
# TODO: have a better way to distinguish haproxy instances

#
# The main description file contains the most fine-granular distribution
# of services. To detect the server when multiple services go on on machine,
# the first service in the "contents" list is used as "primary" service which
# determines the characteristterra of the created service infrastructure
#

// Provider specific configs
provider "opentelekomcloud" {
  region      = "${var.otc_region}"
  domain_name = "${var.otc_tenant}"
  tenant_name = "${var.otc_project}"
  user_name   = "${var.otc_user}"
  password    = "${var.otc_password}"
  auth_url    = "${var.otc_auth_url}"
  cacert_file = "${var.otc_cacert_file}"
}

locals {
  state_dir = "${dirname(var.topo_file)}"

  common_tags = {
    ALERTGROUP     = "${var.ALERTGROUP}"
    APPLICATIONENV = "${var.APPLICATIONENV}"
    BUSINESSUNIT   = "${var.BUSINESSUNIT}"
    CONSUL         = "${var.CONSUL}"
    DOMAIN         = "${var.DOMAIN}"
    INTERNALPROXY  = "${var.INTERNALPROXY}"
    OWNEREMAIL     = "${var.OWNEREMAIL}"
    POD            = "${var.POD}"
  }

  podprefix = "${lower(var.BUSINESSUNIT)}-${lower(var.APPLICATIONENV)}-${lower(var.POD)}"
  PODPREFIX = "${upper(var.BUSINESSUNIT)}-${upper(var.APPLICATIONENV)}-${upper(var.POD)}"
}

# Workaround: avoid creation of existing DNS zones in OpenTelekomCloud
# The terraform provider and terraform itself is not able to find
# out something about existing dns zones, so a native OTC call is required
# This is the token for OTC API. 
data "external" "otc_token" {
  program = ["${path.module}/otc_get_token.sh",
    "--os-username",
    "${var.otc_user}",
    "--os-region-name",
    "${var.otc_region}",
    "--os-password",
    "${var.otc_password}",
    "--os-domain-name",
    "${var.otc_tenant}",
    "--os-project-name",
    "${var.otc_project}",
    "--os-cacert",
    "${var.otc_cacert_file}",
    "--os-auth-url",
    "${var.otc_auth_url}",
    "--os-identity-api-version",
    "3",
  ]
}

###
# Step 1: create KMS Key (if none)
#module "create-kms-key" {
#  source = "kms_key"
#
#  # considered multiple times during plan, but executed only once

#  alias       = "${local.PODPREFIX}-encryption-key"
#  description = "${local.PODPREFIX} Encryption KMS Key"
#  tags        = "${local.common_tags}"
#}

###
# Step 2: Security groups
module "sg-common" {
  source = "security_group/sg_common"

  cidr_blocks_mgmt = "${var.cidr_blocks_mgmt}"
  sg_name          = "${local.PODPREFIX}-COMMON-SG"
  vpc_id           = "${var.vpc_id}"
  tags             = "${local.common_tags}"
}

module "sg-db" {
  source = "security_group/sg_db"

  cidr_blocks_cr  = "${var.cidr_blocks_cr}"
  cidr_blocks_ma  = "${var.cidr_blocks_ma}"
  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "${local.PODPREFIX}-DB-SG"
  vpc_id          = "${var.vpc_id}"
  tags            = "${local.common_tags}"
}

module "sg-efs" {
  source = "security_group/sg_efs"

  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "${local.PODPREFIX}-EFS-SG"
  vpc_id          = "${var.vpc_id}"
  tags            = "${local.common_tags}"
}

module "sg-app" {
  source = "security_group/sg_app"

  cidr_blocks_ma  = "${var.cidr_blocks_ma}"
  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "${local.PODPREFIX}-APP-SG"
  vpc_id          = "${var.vpc_id}"
  tags            = "${local.common_tags}"
}

module "sg-monitor" {
  source = "security_group/sg_monitor"

  cidr_blocks_ma     = "${var.cidr_blocks_ma}"
  cidr_blocks_nagios = "${var.cidr_blocks_nagios}"
  cidr_blocks_pod    = "${var.cidr_blocks_pod}"
  sg_name            = "${local.PODPREFIX}-MONITOR-SG"
  vpc_id             = "${var.vpc_id}"
  tags               = "${local.common_tags}"
}

module "sg-elb" {
  source = "security_group/sg_elb"

  sg_name = "${local.PODPREFIX}-ELB-SG"
  vpc_id  = "${var.vpc_id}"
  tags    = "${local.common_tags}"
}

module "sg_web" {
  source = "security_group/sg_web"

  cidr_blocks_ma  = "${var.cidr_blocks_ma}"
  cidr_blocks_pod = "${var.cidr_blocks_pod}"
  sg_name         = "${local.PODPREFIX}-WEB-SG"
  vpc_id          = "${var.vpc_id}"
  tags            = "${local.common_tags}"
}

###
# Step 3: Create EFS
module "create-efs" {
  source = "efs"

  otc_vpc         = "${var.vpc_id}"
  instance_name   = "${local.PODPREFIX}-EFS"
  subnet_id       = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]
  security_groups = ["${module.sg-efs.security_group_id}"]
  tags            = "${local.common_tags}"
}

###
# Step 4: Create DBs
# The maximal pod is described here. Depending on the service
# distibution, infrsatructure is created only if database is mentioned
# in topo.json
module "create-db-subnet-group" {
  # this is a dummy for OpenTelekomCloud
  source     = "db_subnet_group"
  subnet_ids = ["${var.subnet_db_za}", "${var.subnet_db_zb}"]
  name       = "${local.PODPREFIX}-DB-SUBNETGROUP"
  tags       = "${local.common_tags}"
}

module "create-cms-rds" {
  source       = "topo_rds"
  main_service = "cms-rds"
  topo_file    = "${var.topo_file}"

  #db_subnet_group_name = "${module.create-db-subnet-group.name}"
  db_subnet_group_name = "${var.subnet_db_za}"
  identifier           = "${local.PODPREFIX}-CMS-RDS"

  #kms_key_id           = "${module.create-kms-key.kms_key_id}"
  kms_key_id = ""

  securitygroups = ["${module.sg-db.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${local.common_tags}"

  otc_region        = "${var.otc_region}"
  otc_vpc           = "${var.vpc_id}"
  otc_db_primary_az = "eu-de-01"
  otc_token         = "${data.external.otc_token.result.value}"
}

module "create-terra-rds" {
  source       = "topo_rds"
  main_service = "terra-rds"
  topo_file    = "${var.topo_file}"

  #db_subnet_group_name = "${module.create-db-subnet-group.name}"
  db_subnet_group_name = "${var.subnet_db_za}"
  identifier           = "${local.PODPREFIX}-TERRA-RDS"

  #kms_key_id           = "${module.create-kms-key.kms_key_id}"
  kms_key_id = ""

  securitygroups = ["${module.sg-db.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${local.common_tags}"

  otc_region        = "${var.otc_region}"
  otc_vpc           = "${var.vpc_id}"
  otc_db_primary_az = "eu-de-01"
  otc_token         = "${data.external.otc_token.result.value}"
}

module "create-kms-rds" {
  source       = "topo_rds"
  main_service = "kms-rds"
  topo_file    = "${var.topo_file}"

  #db_subnet_group_name = "${module.create-db-subnet-group.name}"
  db_subnet_group_name = "${var.subnet_db_za}"
  identifier           = "${local.PODPREFIX}-KMS-RDS"

  #kms_key_id           = "${module.create-kms-key.kms_key_id}"
  kms_key_id = ""

  securitygroups = ["${module.sg-db.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${local.common_tags}"

  otc_region        = "${var.otc_region}"
  otc_vpc           = "${var.vpc_id}"
  otc_db_primary_az = "eu-de-01"
  otc_token         = "${data.external.otc_token.result.value}"
}

###
# Step 5: create chef repo, environments & upload cookbooks
#
#
#
module "create-chef-env" {
  source         = "tsys_chef"
  POD            = "${var.POD}"
  APPLICATIONENV = "${var.APPLICATIONENV}"
  BUSINESSUNIT   = "$|var.BUSINESSUNIT}"
  DOMAIN         = "${var.DOMAIN}"
  ma_url         = "$|var.ma_url}"
  pod_url        = "${var.pod_url}"
  root_cert_dir  = "${var.root_cert_dir}"
  haproxy_key    = "${var.haproxy_key}"
  podprefix      = "${local.podprefix}"

  int_haproxy_key = "host-bundle.pem"
  package_url     = "${var.tsys_package_url}"
  cdnURL          = ""
  ipfilter        = ""

  tsys_package_url    = "${var.tsys_package_url}"
  tsys_key_password   = "${var.tsys_key_password}"
  tsys_trust_password = "${var.tsys_trust_password}"

  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
}

###
# Step 6: create HAproxy services with loadbalancers
# The maximal pod is described here. Depending on the service
# distibution, infrsatructure is created only for the main services
# given in topo.json
module "create-external-haproxy" {
  source       = "topo_service"
  main_service = "external-haproxy"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_haproxy_"
  short_name           = "_haproxy_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_web_za}", "${var.subnet_web_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"

  otc_region = "${var.otc_region}"
  otc_vpc    = "${var.vpc_id}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"
  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]
  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "LOADBALANCER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-external-loadbalancer" {
  source       = "topo_elb"
  main_service = "external-elb"
  topo_file    = "${var.topo_file}"

  name               = "${local.PODPREFIX}-EXTERNAL-ELB"
  dns_name           = "${var.pod_url}"
  lb_port            = "443"
  lb_protocol        = "TCP"
  idle_timeout       = "600"
  elb_is_internal    = "false"
  elb_security_group = "${module.sg-elb.security_group_id}"
  ssl_certificate_id = ""

  #subnets             = ["${var.subnet_public_za}", "${var.subnet_public_zb}"]
  backend_port        = "443"
  backend_protocol    = "TCP"
  health_check_target = "TCP:443"
  accept_proxy        = "true"

  instances       = ["${module.create-external-haproxy.ec2_instance_id}"]
  num_backends    = "${module.create-external-haproxy.number_of_instances}"
  otc_backend_ips = ["${module.create-external-haproxy.ec2_instance_private_ip}"]
  otc_vpc         = "${var.vpc_id}"
  otc_region      = "${var.otc_region}"
  otc_token       = "${data.external.otc_token.result.value}"

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "ELB",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-internal-haproxy" {
  source       = "topo_service"
  main_service = "internal-haproxy"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_haproxy_"
  short_name           = "_haproxy_"
  subnets              = ["${var.subnet_web_za}", "${var.subnet_web_zb}"]
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "LOADBALANCER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-internal-loadbalancer" {
  source       = "topo_elb"
  main_service = "internal-elb"
  topo_file    = "${var.topo_file}"

  name                = "${local.PODPREFIX}-internal-elb"
  dns_name            = "${local.podprefix}.${var.DOMAIN}"
  instances           = ["${module.create-internal-haproxy.ec2_instance_id}"]
  num_backends        = "${module.create-internal-haproxy.number_of_instances}"
  lb_port             = "443"
  lb_protocol         = "TCP"
  idle_timeout        = "600"
  elb_is_internal     = "true"
  elb_security_group  = "${module.sg-elb.security_group_id}"
  ssl_certificate_id  = ""
  subnets             = ["${var.subnet_web_za}", "${var.subnet_web_zb}"]
  backend_port        = "443"
  backend_protocol    = "TCP"
  health_check_target = "TCP:443"
  accept_proxy        = "false"

  otc_vpc         = "${var.vpc_id}"
  otc_region      = "${var.otc_region}"
  otc_backend_ips = ["${module.create-internal-haproxy.ec2_instance_private_ip}"]
  otc_token       = "${data.external.otc_token.result.value}"

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "ELB",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-ma-haproxy" {
  source       = "topo_service"
  main_service = "ma-haproxy"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_haproxy_"
  short_name           = "_haproxy_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_web_za}", "${var.subnet_web_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "LOADBALANCER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-ma-loadbalancer" {
  source       = "topo_elb"
  main_service = "ma-elb"
  topo_file    = "${var.topo_file}"

  name                = "${local.PODPREFIX}-MA-ELB"
  dns_name            = "${var.ma_url}"
  instances           = ["${module.create-ma-haproxy.ec2_instance_id}"]
  num_backends        = "${module.create-ma-haproxy.number_of_instances}"
  lb_port             = "443"
  lb_protocol         = "TCP"
  idle_timeout        = "600"
  elb_is_internal     = "false"
  elb_security_group  = "${module.sg-elb.security_group_id}"
  ssl_certificate_id  = ""
  subnets             = ["${var.subnet_public_za}", "${var.subnet_public_zb}"]
  backend_port        = "443"
  backend_protocol    = "TCP"
  health_check_target = "TCP:443"
  accept_proxy        = "false"

  otc_vpc         = "${var.vpc_id}"
  otc_region      = "${var.otc_region}"
  otc_backend_ips = ["${module.create-ma-haproxy.ec2_instance_private_ip}"]
  otc_token       = "${data.external.otc_token.result.value}"

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "ELB",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

###
# Step 6: create services (+additional)
# The maximal pod is described here. Depending on the service
# distibution, infrsatructure is created only for the main services
# given in topo.json
module "create-frs-service" {
  source       = "topo_service"
  main_service = "frs"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_frs_"
  short_name           = "_frs_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-migration-service" {
  source       = "topo_service"
  main_service = "migration-service"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_migration_"
  short_name           = "_migration_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

# TODO: fix topo_service primary service selection from jq
module "create-auditlog-service" {
  source       = "topo_service"
  main_service = "auditlog-service"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_audit_"
  short_name           = "_audit_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-preference-service" {
  source       = "topo_service"
  main_service = "preference-service"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_server_url = "${var.chef_server_url}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_preference_"
  short_name           = "_preference_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-identity-service" {
  source       = "topo_service"
  main_service = "identity-service"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_identity_"
  short_name           = "_identity_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-kafka" {
  source       = "topo_service"
  main_service = "kafka"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_kafka_"
  short_name           = "_kafka_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  #tags = "${local.common_tags}"
  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

###
# Step 6: Create TERRA
module "create-saas-terra" {
  source       = "topo_terra"
  main_service = "saas"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_saas_"
  short_name           = "_saas_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"
  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"

  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]

  efs_ip_address = "${module.create-efs.ip_address}"

  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

module "create-saas-channel-terra" {
  source       = "topo_terra"
  main_service = "saas-channel"
  topo_file    = "${var.topo_file}"

  latest_ami      = "${var.latest_ami}"
  ami_id          = "${var.ami_id}"
  attach_volume   = "true"
  chef_server_url = "${var.chef_server_url}"
  chef_repo_dir   = "${var.chef_repo_dir}"
  chef_user       = "${var.chef_user}"
  chef_user_key   = "${var.chef_user_key}"
  ebs_device_name = "/dev/sdc"

  # the next few varaibles are defaults from pod, but may be overwritten by topo
  ebs_root_volume_iops = "${var.ebs_root_volume_iops}"
  ebs_root_volume_size = "${var.ebs_root_volume_size}"
  ebs_root_volume_type = "${var.ebs_root_volume_type}"
  ebs_root_volume_iops = "${var.ebs_volume_iops}"
  ebs_volume_type      = "${var.ebs_volume_type}"
  prefix               = "${local.PODPREFIX}"
  instance_name        = "_some_kafka_"
  short_name           = "_kafka_"
  key_name             = "${var.key_name}"
  user_key             = "${var.user_key}"
  kms_key_id           = ""
  subnets              = ["${var.subnet_app_za}", "${var.subnet_app_zb}"]

  #kms_key_id             = "${module.create-kms-key.kms_key_id}"

  otc_vpc    = "${var.vpc_id}"
  otc_region = "${var.otc_region}"
  otc_azs    = ["${var.otc_azs}"]
  otc_token  = "${data.external.otc_token.result.value}"
  vpc_security_group_ids = ["${module.sg-common.security_group_id}",
    "${module.sg-app.security_group_id}",
    "${module.sg-monitor.security_group_id}",
  ]
  efs_ip_address = "${module.create-efs.ip_address}"
  tags = "${merge(local.common_tags, map(
    "APPLICATIONROLE", "APPLICATIONSERVER",
    "RUNNINGSCHEDULE", var.RUNNINGSCHEDULE))}"
}

###
# Pre-final step: distribute certificates to nodes
# This step is externalized to a separate module so that the
# setp itself can be executed independently to echange certificates by
# terraform ... -target "module.refresh-certs"
module "refresh-certs" {
  source = "tsys_cert"

  ca_label = "${local.PODPREFIX}"
  base_dir = "${local.state_dir}"

  haproxies = "${merge(
    module.create-external-haproxy.cert_targets,
    module.create-internal-haproxy.cert_targets,
    module.create-ma-haproxy.cert_targets
  )}"

  num_haproxies = "${
    module.create-external-haproxy.number_of_instances +
    module.create-internal-haproxy.number_of_instances +
    module.create-ma-haproxy.number_of_instances
  }"

  saas = "${merge(
    module.create-saas-terra.cert_targets,
    module.create-saas-channel-terra.cert_targets
  )}"

  num_saas = "${
    module.create-saas-terra.number_of_instances +
    module.create-saas-channel-terra.number_of_instances
  }"

  kafka = "${merge(
    module.create-kafka.cert_targets
  )}"

  num_kafka = "${
    module.create-kafka.number_of_instances
  }"

  services = "${merge(
    module.create-identity-service.cert_targets,
    module.create-frs-service.cert_targets,  
    module.create-migration-service.cert_targets,
    module.create-auditlog-service.cert_targets,
    module.create-preference-service.cert_targets
  )}"

  num_services = "${
    module.create-identity-service.number_of_instances +
    module.create-frs-service.number_of_instances +
    module.create-migration-service.number_of_instances +
    module.create-auditlog-service.number_of_instances +
    module.create-preference-service.number_of_instances
  }"

  key_password   = "${var.tsys_key_password}"
  trust_password = "${var.tsys_trust_password}"

  root_cert_dir = "${var.root_cert_dir}"

  ec2_user = "linux"
  user_key = "${var.user_key}"
}

###
# Final handover step to master_deploy:
# Generate a state.sh file which contains the mapping between
# ip addresses and
resource "local_file" "master-deploy-state" {
  filename = "${local.state_dir}/state.sh"

  content = "${join("\n", compact(concat(
    module.create-external-haproxy.masterstate,
    module.create-internal-haproxy.masterstate,
    module.create-ma-haproxy.masterstate,
    module.create-frs-service.masterstate,  
    module.create-migration-service.masterstate,
    module.create-auditlog-service.masterstate,
    module.create-preference-service.masterstate,
    module.create-preference-service.masterstate,
    module.create-identity-service.masterstate,
    module.create-kafka.masterstate,
    module.create-saas-terra.masterstate,
    module.create-saas-channel-terra.masterstate )))}"
}
