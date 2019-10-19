data "opentelekomcloud_rds_flavors_v1" "dbclass" {
  # do not forget to disable dummy calls for disabled moduor calls
  count = "${var.number_of_instances}"

  region = "${var.otc_region}"

  #region           = "${provider.opentelekomcloud.region}"
  datastore_name    = "MySQL"
  datastore_version = "${var.engine_version}"
  speccode          = "${var.instance_class}"
}

locals {
  versionnumbers = "${split(".", var.engine_version)}"
}

resource "opentelekomcloud_rds_instance_v1" "default" {
  count = "${var.number_of_instances}"

  name = "${var.identifier}"

  datastore {
    type    = "MySQL"
    version = "${local.versionnumbers[0]}.${local.versionnumbers[1]}"
  }

  flavorref = "${data.opentelekomcloud_rds_flavors_v1.dbclass.id}"

  volume {
    type = "${var.storage_type}"
    size = "${var.allocated_storage}"
  }

  #region           = "${var.otc_region}"
  availabilityzone = "${var.otc_db_primary_az}"
  vpc              = "${var.otc_vpc}"

  nterra {
    // subnet group equal  a single subnets on OTC 
    // placement of replicated  
    subnetid = "${var.db_subnet_group_name}"

    //subnetid = "${data.opentelekomcloud_networking_network_v2.subnet_id.id}"
  }

  securitygroup {
    id = "${var.securitygroups[0]}"
  }

  dbport = "8635"

  backupstrategy = {
    starttime = "${var.backup_window}"
    keepdays  = "${var.backup_retention_period}"
  }

  dbrtpd = "${var.password}"

  ha = {
    enable          = "${var.multi_az}"
    replicationmode = "async"
  }

  // TODO: encrypted RDS storage (comes with summer release, terraform to adapt)
  // kms_key_id              = "${var.kms_key_id}"
  // storage_encrypted       = "${var.storage_encrypted}"


  // TODO: tags for DB instances (to come with OTC summer release?)
  // tags                    = "${merge(var.tags,
  //                             map("NAME", format("%s-rds", var.identifier)),
  //                             map("Name", format("%s-rds", var.identifier)))}"


  // Not relevant for OTC
  // parameter_group_name    = "${var.parameter_group_name}"
  // iops                    = "${var.iops}"
  // maintenance_window      = "${var.maintenance_window}"
  // skip_final_snapshot     = "${var.skip_final_snapshot}"
  // username                = "${var.username}"
  // auto_minor_version_upgrade = "${var.auto_minor_version_upgrade}"

  # ignore datastore.version,
  # database will change as soon as a different flavor is found
  # (which is the most granular change)
  # ignore id and make name the leading criteria for re-creation
  lifecycle {
    ignore_changes = ["name", "datastore"]

    # ignore_changes = ["id", "name", "datastore"] 
  }
}

module "create-rds-dns" {
  source = "../route53_record"

  num_entries   = "${var.number_of_instances>0 ? 1 : 0 }"
  dns_zone_name = "${var.tags["DOMAIN"]}"
  names         = ["${var.identifier}"]
  ips           = ["${opentelekomcloud_rds_instance_v1.default.*.hostname}"]

  // internal zones are scoped for dedicated VPCs. do not forget to add DNS
  // entries for management vpc!
  otc_region = "${var.otc_region}"

  otc_zone_type = "private"
  otc_dns_vpcs  = ["${var.otc_vpc}"]
  otc_token     = "${var.otc_token}"
}
