module "create-ec2-sampleterra" {
  source = "../terra"

  AMIIDQUERY             = "BASEAMIRHEL7"
  latest_ami             = "true"
  ami_id                 = ""
  attach_volume          = "true"
  chef_env_name          = "${var.chef_env_name}"
  chef_url               = "${var.chef_url}"
  chef_user              = "${var.chef_user}"
  run_list               = [""]
  chef_user_key          = "${var.chef_user_key}"
  ebs_device_name        = ""                          //unused, module accepts system default device
  ebs_mount_point        = "/opt"
  ebs_root_volume_iops   = ""                          // unused
  ebs_root_volume_size   = "10"
  ebs_root_volume_type   = "SSD"
  ebs_volume_iops        = ""                          // unused
  ebs_volume_size        = "100"
  ebs_volume_type        = "SAS"
  ec2_user               = "${var.ec2_user}"
  enable_encrypted_ebs   = "false"
  iam_instance_profile   = ""                          // unused
  instance_name          = "doaas-pod1-terra-test"
  instance_type          = "s2.xlarge.4"
  key_name               = "${var.key_name}"
  user_key               = "${var.user_key}"
  kms_key_id             = ""                          // not used yet, for encrypted drives
  number_of_instances    = "1"
  short_name             = "ITERRA-SAMPLE-SERVICE-NODE"
  otc_vpc                = "${var.vpc_id}"
  subnets                = "${var.subnets}"
  otc_azs                = "${var.otc_azs}"
  swap_memory            = "2"
  vpc_security_group_ids = "${var.security_group_ids}"

  // TERRA setup
  terra_user       = "doaasterra"
  mount_efs      = true
  efs_ip_address = "§{var.efs_ip_address}"

  // NAME, Name and SHORT_HOSTNAME will be generated in runtime
  tags {
    ALERTGROUP      = "iterra_team"
    APPLICATIONENV  = "QA"
    APPLICATIONROLE = "APPSERVER"
    BUSINESSUNIT    = "ITERRA"
    CONSUL          = "consulnp-uswest2-cloudtrust-rocks"
    DOMAIN          = "dooascloud-com"
    INTERNALPROXY   = "OFF"

    //OWNEREMAIL      = "tim-busch--t-systems-com"
    RUNNINGSCHEDULE = "00_00_23_59_1-7"
  }
}
