provider "opentelekomcloud" {
  region      = "${var.region}"
  domain_name = "${var.otc_tenant}"
  tenant_name = "${var.otc_project}"
  user_name   = "${var.otc_user}"
  password    = "${var.otc_password}"
  auth_url    = "${var.otc_auth_url}"
  cacert_file = "${var.otc_cacert_file}"
}

data "opentelekomcloud_vpc_v1" "admin_vpc" {
	name = "${var.mgmt_vpc}"
}

data "opentelekomcloud_vpc_subnet_v1" "admin_sn" {
  vpc_id = "${data.opentelekomcloud_vpc_v1.admin_vpc.id}"
	name   = "${var.mgmt_subnet}"
}

/**
 * Stage 1(security option): Create a new (onetime) key for the masterimage
 * per image release
 * note that the keys are not deleted on destroy for reuse

resource "null_resource" "user_keygen" {
  triggers = {
    keyname = "${var.user_key}"
  }

  provisioner "local-exec" {
    # TODO: may add password to the keyfile
    command = "ssh-keygen -q -t ecdsa -b 521 -N \"\" -f ${var.user_key} -C \"dooas-deploy\""

    # command = "ssh-keygen -t rsa -b 4096 -N \"\" -f ${var.user_key} -C \"dooas-deploy\""
    on_failure = "continue"
  }
}

data "local_file" "user_pub_key" {
  depends_on = ["null_resource.user_keygen"]
  filename   = "${var.user_key}.pub"
}

resource "opentelekomcloud_compute_keypair_v2" "doaas-api-user" {
  name       = "${var.key_name}"
  public_key = "${data.local_file.user_pub_key.content}"

  # TODO: workaround for provider bugs
  lifecycle {
    ignore_changes  = ["id", "public_key"]
    prevent_destroy = "true"
  }
}
*/

/**
 * Stage 2: Create a private, ephemeral server with natting
 * access to internet in management zone
 */
data "local_file" "user_priv_key" {
  # depends_on = ["opentelekomcloud_compute_keypair_v2.doaas-api-user"]
  filename   = "${var.user_key}"
}

locals {
  os_access = "--os-region-name \"${var.region}\" --os-username \"${var.otc_user}\" --os-password \"${var.otc_password}\" --os-domain-name \"${var.otc_tenant}\" --os-project-name \"${var.otc_project}\" --os-cacert ${var.otc_cacert_file} --os-identity-api-version 3"
}


data "opentelekomcloud_images_image_v2" "otcimage" {
  # name = "Enterprise_RedHat_7_prev"
  name        = "Enterprise_RedHat_7_latest"
  most_recent = true
}

resource "opentelekomcloud_blockstorage_volume_v2" "bakery_boot" {
  name              = "${format("%s-%s-bootdisk", var.image_name, var.image_version)}"
  availability_zone = "eu-de-02"
  size              = "${var.image_size}"
  volume_type       = "SATA"                                                           // to save some pennies
  image_id          = "${data.opentelekomcloud_images_image_v2.otcimage.id}"
}

resource "opentelekomcloud_compute_instance_v2" "bakery" {
  availability_zone = "eu-de-02"
  name              = "doaas-baseimage-bakery"
  flavor_id         = "s2.medium.4"
  # key_pair          = "${opentelekomcloud_compute_keypair_v2.doaas-api-user.name}"
  key_pair          = "${var.key_name}"
  security_groups   = "${var.mgmt_security_groups}"
  tags              = ["BAKERY.${data.opentelekomcloud_images_image_v2.otcimage.name}"]

  block_device {
    uuid             = "${opentelekomcloud_blockstorage_volume_v2.bakery_boot.id}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
    volume_size      = "${var.image_size}"

    //TODO: temporary disabled due to OTC image creatioon problem:
    // we must keep the volume to create servers from created image
    delete_on_termination = true
  }

  network {
    uuid = "${data.opentelekomcloud_vpc_subnet_v1.admin_sn.id}"
  }

  ###
  # Put all the hardening scripts for image here
  provisioner "remote-exec" {
    scripts = ["./manage_packages.sh",
      # "./manage_kernel_modules.sh",
      # "./install-chef.sh",
    ]
  }

  # cleanup all images with the same name
  #provisioner "local-exec" {
  #  when = "destroy"
  #  command = "openstack image delete --name \"${var.image_name}-${var.image_version}\" --wait ${local.os_access}"
  #}

  /**
   * Stage 3: create image
   * It requires server control commands that are not supported by
   * Terraform yet.
   * Due to a (current) bug in OTC, you have to go via volume and cinder to
   * create an image from a server to be available in all AZ
   */
  provisioner "local-exec" {
    command = "./os-create-image-fix.sh ${opentelekomcloud_compute_instance_v2.bakery.id} ${opentelekomcloud_blockstorage_volume_v2.bakery_boot.id} \"${var.image_name}-${var.image_version}\" \"${var.otc_auth_url}\" ${local.os_access}"
  }
  connection {
    type        = "ssh"
    user        = "${var.ec2_user}"
    host        = "${opentelekomcloud_compute_instance_v2.bakery.network.0.fixed_ip_v4}"
    private_key = "${data.local_file.user_priv_key.content}"
  }
}
