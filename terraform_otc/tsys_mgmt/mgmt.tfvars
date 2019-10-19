  mgmt_vpc_name          = "doaas-mgmt"

  ec2_user               = "linux"
  mgmt_user_key          = "/home/linux/.ssh/doaas_mgmt_xxxxxxx.pem"
  mgmt_key_name          = "doaas_mgmt"

  chef_user              = "doaaschef"
  chef_password          = "yyyyyyyyyyyyyyy"
  chef_longname          = "Tim Busch"
  chef_email             = "tim.busch@t-systems.com"
  chef_keyfile           = "/home/linux/.ssh/doaaschef.pem"

  chef_env_name          = "doaas"
  chef_longorg           = "Data orchestration as a service"

  otc_region             = "eu-de"
  otc_project            = "eu-de_doaaspoc"
  otc_tenant             = "OTC-EU-DE-0000000000100xxxxxxxxx"
  // TODO: access information to be taken from a secure wallet
  // see terraform manual for details
  otc_user               = "doaas_mgmt"
  otc_password           = "xxxxxxxxxxxx"

