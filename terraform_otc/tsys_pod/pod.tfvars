  BUSINESSUNIT           = "doaas"
  APPLICATIONENV         = "dev"
  POD                    = "poc1"

  otc_region             = "eu-de"
  otc_project            = "eu-de_doaas"
  otc_tenant             = "OTC-EU-DE-0000000000100xxxxxxxx"
  // TODO: access information to be taken from a secure wallet
  // see terraform manual for details
  otc_user               = "doaas_api"
  otc_password           = "xxxxxxxx"

  // need for ObjectStore access; generate in console
  otc_ak                 = "xxxxxxxx"
  otc_sk                 = "xxxxxxxx"

  cidr_blocks_ma         = "10.33.0.0/16",
  cidr_blocks_mgmt       = "172.30.0.0/20",
  cidr_blocks_pod        = "10.33.0.0/16",

  mgmt_vpc               = "vpc-doaas-mgmt"
  mgmt_chef_ip           = "172.30.10.50"
  mgmt_consul_ip         = "0.0.0.0

  tsys_code_server            = "obs.eu-de.otc.t-systems.com"
  tsys_code_localdir          = "/home/linux/r29_code"
  tsys_code_bucket_name       = "099003-doaasd-dev-poc1"
