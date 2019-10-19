  image_name             = "dooas-rhel7-chef-baseimage"
  image_version          = "0.99.01"
  image_size             = 14
  key_name               = "doaas_xxxx"
  user_key               = "/home/linux/.ssh/xxxxxxx.pem"
  ec2_user               = "linux"

  otc_region             = "eu-de"
  otc_project            = "eu-de_doaaspoc"
  otc_tenant             = "OTC-EU-DE-000000000010000xxxxxx"
  // TODO: access information to be taken from a secure wallet
  // see terraform manual for details
  otc_user               = "doaas_xxxx"
  otc_password           = "xxxxxxxx"
  otc_cacert_file        = "../terraform_otc/otc_certs.pem"

  mgmt_vpc               = "vpc-doaas-mgmt"
  mgmt_subnet_id         = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  mgmt_security_groups   = ["sg-doaas-mgmt"]
