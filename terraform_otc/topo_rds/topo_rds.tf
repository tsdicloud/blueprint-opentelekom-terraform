data "external" "topo" {
  # Select the section of the primary service and make it a flat list of
  # strings
  program = ["jq", "[.[]|select(.tf_type==\"rds\")|select( .contents[]|contains(\"${var.main_service}\"))|.contents|=join(\",\")|.[]|=if type==\"number\" then tostring else . end]+[{}]|.[0]", "${var.topo_file}"]
}

locals {
  # enable or disable
  number_of_instances = "${lookup(data.external.topo.result, "tf_type", "")!="" ? 1 : 0 }"

  # detect existence of data in locals
  contents                   = "${lookup(data.external.topo.result, "contents", "")}"
  run_list                   = "${split(",", local.contents)}"
  allocated_storage          = "${lookup(data.external.topo.result, "allocated_storage", var.allocated_storage)}"
  auto_minor_version_upgrade = "${lookup(data.external.topo.result, "auto_minor_version_upgrade", var.auto_minor_version_upgrade)}"
  backup_retention_period    = "${lookup(data.external.topo.result, "backup_retention_period", var.backup_retention_period)}"
  backup_window              = "${lookup(data.external.topo.result, "backup_window", var.backup_window)}"
  engine_version             = "${lookup(data.external.topo.result, "engine_version", var.engine_version)}"
  instance_class             = "${lookup(data.external.topo.result, "instance_class", var.instance_class)}"
  iops                       = "${lookup(data.external.topo.result, "iops", var.iops)}"
  maintenance_window         = "${lookup(data.external.topo.result, "maintenance_window ", var.maintenance_window)}"
  multi_az                   = "${lookup(data.external.topo.result, "multi_az", var.multi_az)}"
  parameter_group_name       = "${lookup(data.external.topo.result, "parameter_group_name", var.parameter_group_name)}"
  password                   = "${lookup(data.external.topo.result, "password", var.password)}"
  skip_final_snapshot        = "${lookup(data.external.topo.result, "skip_final_snapshot", var.skip_final_snapshot) }"
  storage_encrypted          = "${lookup(data.external.topo.result, "storage_encrypted", var.storage_encrypted)}"
  storage_type               = "${lookup(data.external.topo.result, "storage_type", var.storage_encrypted)}"
  username                   = "${lookup(data.external.topo.result, "username", var.username)}"
}

module "create-topo-rds" {
  source = "../rds"

  number_of_instances = "${local.number_of_instances}"

  engine_version             = "${local.engine_version}"
  storage_type               = "${local.storage_type}"
  allocated_storage          = "${local.allocated_storage}"
  instance_class             = "${local.instance_class}"
  username                   = "${local.username}"
  password                   = "${local.password}"
  db_subnet_group_name       = "${var.db_subnet_group_name}"
  parameter_group_name       = "${local.parameter_group_name}"
  securitygroups             = "${var.securitygroups}"
  backup_retention_period    = "${local.backup_retention_period}"
  identifier                 = "${var.identifier}"
  skip_final_snapshot        = "${local.skip_final_snapshot}"
  auto_minor_version_upgrade = "${local.auto_minor_version_upgrade}"

  tags = "${var.tags}"

  otc_region        = "${var.otc_region}"
  otc_vpc           = "${var.otc_vpc}"
  otc_db_primary_az = "${var.otc_db_primary_az}"
  otc_token         = "${var.otc_token}"
}
