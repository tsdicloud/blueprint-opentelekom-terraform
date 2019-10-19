output "ip_address" {
  value = "${opentelekomcloud_sfs_file_system_v2.efs.export_location}"
}

output "efs_id" {
  value = "${opentelekomcloud_sfs_file_system_v2.efs.id}"
}
