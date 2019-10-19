output "security_group_id" {
  value = "${opentelekomcloud_networking_secgroup_v2.sg_common.id}"

  #  value = "${data.null_data_source.keep_sg_common_rules.outputs["id"]}"
}
