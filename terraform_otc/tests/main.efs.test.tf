module "create-efs-doaas-test" {
  source = "../efs"

  otc_sfs_size = 1

  instance_name   = "efs-test"
  subnet_id       = [""]       // unused
  security_groups = [""]       // unused

  tags {
    ALERTGROUP      = "iterra_team"
    APPLICATIONENV  = "QA"
    APPLICATIONROLE = "RDS"
    BUSINESSUNIT    = "terra"
    DOMAIN          = "infacloudops.net"
    OWNEREMAIL      = "rg@terra.com"
    RUNNINGSCHEDULE = "00:00:23:59:1-7"
  }
}
