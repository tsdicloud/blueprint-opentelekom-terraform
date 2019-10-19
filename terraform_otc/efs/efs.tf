resource "opentelekomcloud_sfs_file_system_v2" "efs" {
  share_proto       = "NFS"
  name              = "${var.instance_name}"
  size              = "${var.otc_sfs_size}"
  availability_zone = "eu-de-01"             // OTC only supports one az im eu-de-01
  access_level      = "rw"
  access_to         = "${var.otc_vpc}"
  access_type       = "cert"

  // TODO: OTC tags not implemented in Terraform provider
  // tags           = "${merge(var.tags,
  //                             map("NAME", var.instance_name),
  //                             map("Name", var.instance_name))}"

  lifecycle {
    ignore_changes = "metadata"
  }
}
