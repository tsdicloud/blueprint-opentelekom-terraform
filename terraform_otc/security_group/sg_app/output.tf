output "security_group_id" {
  value = "${opentelekomcloud_networking_secgroup_v2.sg_app.id}"
}
