// Dependency
terraform {
  required_version = "> 0.11.6"
}

data "external" "topo" {
  # Select the section of the primary service and make it a flat list of 
  # strings
  program = ["jq", "[.[]|select(.tf_type==\"service\")|select( .contents[0]==\"${var.main_service}\")|.contents|=join(\",\")|.[]|=if type==\"number\" then tostring else . end]+[{}]|.[0]", "${var.topo_file}"]
}

locals {
  # enable or disable 
  number_of_instances = "${lookup(data.external.topo.result, "count", 0) }"

  # detect existence of data in locals
  contents             = "${lookup(data.external.topo.result, "contents", "")}"
  run_list             = "${split(",", local.contents)}"
  services             = "${join(" ", local.run_list)}"
  chef_env_name        = "${lookup(data.external.topo.result, "chef_env_name", var.chef_env_name)}"
  ebs_mount_point      = "${lookup(data.external.topo.result, "ebs_mount_point", var.ebs_mount_point)}"
  ebs_root_volume_iops = "${lookup(data.external.topo.result, "ebs_root_volume_iops", var.ebs_root_volume_iops)}"
  ebs_root_volume_size = "${lookup(data.external.topo.result, "ebs_root_volume_size", var.ebs_root_volume_size)}"
  ebs_root_volume_type = "${lookup(data.external.topo.result, "ebs_root_volume_type", var.ebs_root_volume_type)}"
  ebs_volume_iops      = "${lookup(data.external.topo.result, "ebs_volume_iops", var.ebs_volume_iops)}"
  ebs_volume_size      = "${lookup(data.external.topo.result, "ebs_volume_size", var.ebs_volume_size)}"
  ebs_volume_type      = "${lookup(data.external.topo.result, "ebs_volume_type", var.ebs_volume_type)}"
  ec2_user             = "${lookup(data.external.topo.result, "ec2_user", var.ec2_user)}"
  service_user         = "${lookup(data.external.topo.result, "service_user", "tomcat")}"
  iam_instance_profile = "${lookup(data.external.topo.result, "iam_iinstane_profile", var.iam_instance_profile)}"
  instance_type        = "${lookup(data.external.topo.result, "instance_type", var.instance_type)}"
  platform             = "${lookup(data.external.topo.result, "platform", var.AMIIDQUERY) }"
  prefix               = "${lookup(data.external.topo.result, "prefix", var.prefix)}"
  topo_short_name      = "${lookup(data.external.topo.result, "short_name", "_none_")}"
  instance_name        = "${upper(local.prefix)}-${upper(local.topo_short_name)}"
  short_name           = "${lower(local.topo_short_name)}"
  swap_memory          = "${lookup(data.external.topo.result, "swap_memory", "16")}"
  APPLICATIONROLE      = "${lookup(data.external.topo.result, "APPLICATIONROLE", var.tags["APPLICATIONROLE"])}"
}

module "create-topo-service" {
  source = "../service"

  AMIIDQUERY             = "${local.platform}"
  latest_ami             = "${var.latest_ami}"
  ami_id                 = "${lookup(var.ami_id,local.platform,"")}"
  attach_volume          = "true"
  chef_server_url        = "${var.chef_server_url}"
  chef_env_name          = "${local.chef_env_name}"
  chef_repo_dir          = "${var.chef_repo_dir}"
  chef_user              = "${var.chef_user}"
  chef_user_key          = "${var.chef_user_key}"
  run_list               = "${local.run_list}"
  ebs_device_name        = "${var.ebs_device_name}"
  ebs_mount_point        = "${local.ebs_mount_point}"
  ebs_root_volume_iops   = "${local.ebs_root_volume_iops}"
  ebs_root_volume_size   = "${local.ebs_root_volume_size}"
  ebs_root_volume_type   = "${local.ebs_root_volume_type}"
  ebs_volume_iops        = "${local.ebs_volume_iops}"
  ebs_volume_size        = "${local.ebs_volume_size}"
  ebs_volume_type        = "${local.ebs_volume_type}"
  ec2_user               = "${local.ec2_user}"
  service_user           = "${local.service_user}"
  enable_encrypted_ebs   = "${var.enable_encrypted_ebs}"
  iam_instance_profile   = "${local.iam_instance_profile}"
  instance_name          = "${local.instance_name}"
  instance_type          = "${local.instance_type}"
  key_name               = "${var.key_name}"
  user_key               = "${var.user_key}"
  kms_key_id             = "${var.kms_key_id}"
  number_of_instances    = "${local.number_of_instances}"
  short_name             = "${local.short_name}"
  subnets                = "${var.subnets}"
  swap_memory            = "${local.swap_memory}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"

  // NAME, Name and SHORT_HOSTNAME will be generated at runtime
  tags = "${merge(var.tags, 
                   map("APPLICATIONROLE", local.APPLICATIONROLE))}"

  otc_vpc    = "${var.otc_vpc}"
  otc_region = "${var.otc_region}"
  otc_azs    = "${var.otc_azs}"
  otc_token  = "${var.otc_token}"
}
