module "create-rds-pc2cloud" {
  source = "../rds"

  engine_version             = "5.7.17"
  storage_type               = "ULTRAHIGH"
  allocated_storage          = 100
  instance_class             = "rds.mysql.s1.large"
  username                   = ""
  password                   = "r00t-Admin"
  otc_region                 = "${var.otc_region}"
  otc_vpc                    = "${var.vpc_id}"
  otc_db_primary_az          = "eu-de-01"
  db_subnet_group_name       = "${var.db_subnet}"
  parameter_group_name       = ""
  securitygroups             = "${var.db_security_group_ids}"
  backup_retention_period    = "2"
  identifier                 = "iterra-qaml-pod1-pc2cloud-db"
  skip_final_snapshot        = ""
  auto_minor_version_upgrade = false                          // unused by OTC

  tags {
    ALERTGROUP      = "iterra_team"
    APPLICATIONENV  = "QA"
    APPLICATIONROLE = "RDS"
    BUSINESSUNIT    = "ITERRA"
    DOMAIN          = "infacloudops.net"
    OWNEREMAIL      = "rg@terra.com"
    RUNNINGSCHEDULE = "00:00:23:59:1-7"
  }
}
