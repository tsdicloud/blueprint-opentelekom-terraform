  image_name             = "dooas-rhel7-chef-baseimage"
  image_version          = "0.99.01"
  image_size             = 14
  
  key_name               = "brederle-master"
  user_key               = "/home/linux/.ssh/brederle-master-317.pem"
  ec2_user               = "linux"

  region                 = "eu-de"
  otc_project            = "eu-de_signicat"
  otc_tenant             = "OTC00000000001000000317"
  // TODO: access information to be taken from a secure wallet
  // see terraform manual for details
  otc_user               = "brederle"
  otc_password           = "SoC0mplicated4MX"
  otc_cacert_file        = "otc_certs.pem"

  mgmt_vpc               = "sigc-adminzone-vpc"
  mgmt_subnet            = "sigc-adminzone-primary-sn"
  mgmt_security_groups   = ["sigc-admin1-sg"]
