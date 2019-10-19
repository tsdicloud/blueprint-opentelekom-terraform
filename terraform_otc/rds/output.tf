output "db_instance_id" {
  value = ["${opentelekomcloud_rds_instance_v1.default.*.id}"]
}

output "db_instance_address" {
  value = ["${opentelekomcloud_rds_instance_v1.default.*.hostname}"]
}
