  key_name               = "doaas_deploy"
  user_key              = "/home/linux/.ssh/doaas_deploy.pem"
  ec2_user               = "linux"

  otc_azs                = ["eu-de-01", "eu-de-02"]
  otc_vpc_id             = "d63bdd29-cba8-4914-aabf-2e4ce50e97f0"
  otc_dns_vpcs           = ["d63bdd29-cba8-4914-aabf-2e4ce50e97f0", "26bd29ff-c60f-43c8-917a-eb598d26d0b2"]

  cidr_blocks_mgmt       = "172.30.0.0/16"
  cidr_blocks_cr         = "10.33.64.0/20"
  cidr_blocks_ma         = "10.33.0.0/20"
  cidr_blocks_pod        = "10.33.128.0/20"
  cidr_blocks_nagios     = "172.30.128.0/20"

  chef_keyfile           = "/home/linux/.ssh/doaaschef.pem"
  chef_env_name          = "test"
  chef_user              = "doaaschef"
  chef_url               = "https://chef.doaascloud-internal.net/organisations/doaas"

  efs_ip_address         = "sfs-nas1.eu-de.otc.t-systems.com:/share-6dc0fb3b"

  # tst_subnets                = ["24023e4c-5e37-4fa2-81c0-7dfd8b6e43d3", "f8191f94-cbc8-446e-b823-6b65ba62d044"]  
  subnets                = ["24023e4c-5e37-4fa2-81c0-7dfd8b6e43d3", "24023e4c-5e37-4fa2-81c0-7dfd8b6e43d3"]  
  security_group_ids     = ["1b3c274e-5d1a-42ca-b32a-0a9018ebc538", "adf31b05-33ca-462e-b626-d55bebbd68b0"]

  db_subnet              = "98d567f6-3f2d-4e1b-b0e0-0c8ee6953584"  
  db_security_group_ids  = ["1b3c274e-5d1a-42ca-b32a-0a9018ebc538", "5c502204-aff2-4be7-b7c1-018063eca1b8"]

  otc_region             = "eu-de"
  otc_project            = "eu-de_doaaspoc"
  otc_tenant             = "OTC-EU-DE-000000000010000xxxxx"
  // TODO: access information to be taken from a secure wallet
  // see terraform manual for details
  otc_user               = "doaas_xxxx"
  otc_password           = "xxxxxxxxx"
  otc_cacert_file        = "../otc_certs.pem"
