provider "opentelekomcloud" {
  region      = "${var.otc_region}"
  domain_name = "${var.otc_tenant}"
  tenant_name = "${var.otc_project}"
  user_name   = "${var.otc_user}"
  password    = "${var.otc_password}"
  auth_url    = "${var.otc_auth_url}"
  cacert_file = "${var.otc_cacert_file}"
}

##
# Stage 1: Generate mgmt ssh key
#
resource "null_resource" "user_keygen" {
  triggers = {
    keyname = "${var.mgmt_user_key}"
  }

  provisioner "local-exec" {
    # TODO: may add password to the keyfile
    command = "ssh-keygen -q -t ecdsa -b 521 -N \"\" -f ${var.mgmt_user_key} -C \"dooas-deploy\""

    # command = "ssh-keygen -t rsa -b 4096 -N \"\" -f ${var.mgmt_user_key} -C \"dooas-deploy\""
    on_failure = "continue"
  }
}

data "local_file" "user_pub_key" {
  depends_on = ["null_resource.user_keygen"]
  filename   = "${var.mgmt_user_key}.pub"
}

resource "opentelekomcloud_compute_keypair_v2" "doaas-api-user" {
  name       = "${var.mgmt_key_name}"
  public_key = "${data.local_file.user_pub_key.content}"

  # TODO: workaround for provider bugs
  lifecycle {
    ignore_changes  = ["id", "public_key"]
    prevent_destroy = "true"
  }
}

##
# Stage 2: VPC, subnets analog to AWS
#
resource "opentelekomcloud_vpc_v1" "iterra_mgmt_vpc" {
  name = "vpc-${var.mgmt_vpc_name}"
  cidr = "172.30.0.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_mgmt_jump" {
  name       = "sn-${var.mgmt_vpc_name}-jump"
  vpc_id     = "${opentelekomcloud_vpc_v1.iterra_mgmt_vpc.id}"
  cidr       = "172.30.0.0/20"
  gateway_ip = "172.30.0.1"
  dns_list   = ["100.125.4.25", "8.8.8.8"]
}

resource "opentelekomcloud_networking_secgroup_v2" "sg_doaas_mgmt" {
  name                 = "${upper(var.mgmt_vpc_name)}-SG"
  description          = "Allow all port 22 traffic incoming and within zone"
  delete_default_rules = false
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "mgmt_ssh_port" {
  direction         = "ingress"
  port_range_min    = 22
  port_range_max    = 22
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_doaas_mgmt.id}"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_group_ips" {
  direction         = "ingress"
  protocol          = ""                                                            //
  ethertype         = "IPv4"
  security_group_id = "${opentelekomcloud_networking_secgroup_v2.sg_doaas_mgmt.id}"
  remote_group_id   = "${opentelekomcloud_networking_secgroup_v2.sg_doaas_mgmt.id}"

  // description     = "Allowing All inbound from same security group"
}

##
# Stage 3: Create DOaaS terraform/chef controller
#
data "local_file" "user_priv_key" {
  depends_on = ["null_resource.user_keygen"]
  filename   = "${var.mgmt_user_key}"
}

data "opentelekomcloud_images_image_v2" "mgmtimage" {
  name        = "Enterprise_RedHat_7_latest"
  most_recent = true
}

resource "opentelekomcloud_blockstorage_volume_v2" "bootvol" {
  name              = "doaas-terrachef-ontroller-bootdisk"
  availability_zone = "eu-de-01"
  size              = "20"
  volume_type       = "SSD"
  image_id          = "${data.opentelekomcloud_images_image_v2.mgmtimage.id}"

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

resource "opentelekomcloud_compute_instance_v2" "jumpserver" {
  availability_zone = "eu-de-01"
  name              = "doaas-terrachef-controller"
  flavor_id         = "s2.medium.4"
  key_pair          = "${opentelekomcloud_compute_keypair_v2.doaas-api-user.name}"
  security_groups   = ["${opentelekomcloud_networking_secgroup_v2.sg_doaas_mgmt.id}"]

  block_device {
    uuid                  = "${opentelekomcloud_blockstorage_volume_v2.bootvol.id}"
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid = "${opentelekomcloud_vpc_subnet_v1.subnet_mgmt_jump.id}"
  }

  lifecycle {
    ignore_changes = ["security_groups"]
  }
}

resource "opentelekomcloud_vpc_eip_v1" "mgmt_eip" {
  lifecycle {
    prevent_destroy = true
  }

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "bandwidth-terrachef-controller"
    size        = 50
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "mgmt_eip_jump" {
  floating_ip = "${opentelekomcloud_vpc_eip_v1.mgmt_eip.publicip.0.ip_address}"
  instance_id = "${opentelekomcloud_compute_instance_v2.jumpserver.id}"

  lifecycle {
    ignore_changes = ["id", "instance_id"]
  }

  ###
  # Put all the hardening scripts for image here
  provisioner "remote-exec" {
    scripts = ["./terraform-chef-controller.sh"]
  }

  # Create chef user and org
  provisioner "remote-exec" {
    inline = [
      "sudo chef-server-ctl reconfigure",
      "sudo chef-server-ctl user-create ${var.chef_user} ${var.chef_longname} ${var.chef_email} '${var.chef_password}' -f ${var.chef_keyfile}",
      "sudo chef-server-ctl org-create ${var.chef_env_name} '${var.chef_longorg}' --association_user ${var.chef_user} -f ${var.chef_keyfile}",
      "sudo chef-server-ctl install opscode-manage",
      "sudo opscode-manage-ctl reconfigure",
      "sudo chef-server-ctl reconfigure",
    ]
  }

  connection {
    type        = "ssh"
    user        = "${var.ec2_user}"
    host        = "${opentelekomcloud_vpc_eip_v1.mgmt_eip.publicip.0.ip_address}"
    private_key = "${data.local_file.user_priv_key.content}"
  }
}

module "create-chef-dns" {
  source = "../terraform_otc/route53_record"

  ips      = "${opentelekomcloud_compute_instance_v2.jumpserver.*.network.0.fixed_ip_v4}"
  dns_name = "chef.internal.doaas"

  // internal zones are scoped for dedicated VPCs. do not forget to add DNS
  // entries for management vpc!
  otc_region = "${var.otc_region}"

  otc_dns_vpcs = "${opentelekomcloud_vpc_v1.iterra_mgmt_vpc.*.id}"
}

# TODO: autonate installation of NATTING gateway for mgmt zone

