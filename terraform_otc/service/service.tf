// Dependency
terraform {
  required_version = "> 0.11.6"
}

// Get the latest base AMI
data "opentelekomcloud_images_image_v2" "baseami" {
  count       = "${var.latest_ami=="true" ? 1 : 0}"
  tag         = "AMIID.${var.AMIIDQUERY}"
  most_recent = "true"

  // OTC only searches for images with state = "available"
}

locals {
  tag_pattern = "/[^a-zA-Z0-9|]+/"

  # this is how the terraform migration guide recommends to handle empty
  # datasets
  image_id = "${element(concat(data.opentelekomcloud_images_image_v2.baseami.*.id, list(var.ami_id)), 0)}"
}

resource "opentelekomcloud_blockstorage_volume_v2" "bootvol" {
  count             = "${var.number_of_instances}"
  name              = "${format("%s-%d-bootdisk", var.instance_name, count.index+1)}"
  availability_zone = "${var.otc_azs[count.index % length(var.otc_azs)]}"
  size              = "${var.ebs_root_volume_size}"
  volume_type       = "${var.ebs_root_volume_type}"
  image_id          = "${local.image_id}"

  // NOT USED by OTC: iops = "${var.ebs_root_volume_iops}"

  // this strange code safeguards from the strange format expected 
  // by OTC with tags
  // OTC can only hold 10 tags per instance with strict syntax
  tags = "${zipmap( 
             split( "|",
               replace( join("|", keys(var.tags)), 
                  local.tag_pattern, "_")),
             split( "|", 
              replace( join("|", values(var.tags)),
                  local.tag_pattern, "-"))
          )}"

  #tags = "${zipmap( 
  #           split( "|",
  #             replace( join("|", concat(keys(var.tags),list( 
  #                "NAME", "SHORT_HOSTNAME" ))),
  #                local.tag_pattern, "_")),
  #           split( "|", 
  #            replace( join("|",concat( values(var.tags), list(
  #                format("%s-%d", var.instance_name, count.index+1),
  #                format("%s%02d", var.short_name, count.index+1)) )),
  #                local.tag_pattern, "-"))
  #        )}"

  // TODO: System boot volumes should not be encrypted on OTC
}

resource "opentelekomcloud_compute_instance_v2" "ec2_instance" {
  count             = "${var.number_of_instances}"
  name              = "${format("%s-%d", var.instance_name, count.index+1)}"
  availability_zone = "${var.otc_azs[count.index % length(var.otc_azs)]}"
  flavor_name       = "${var.instance_type}"
  key_pair          = "${var.key_name}"
  security_groups   = ["${var.vpc_security_group_ids}"]

  block_device {
    uuid                  = "${opentelekomcloud_blockstorage_volume_v2.bootvol.*.id[count.index]}"
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = "0"
    delete_on_termination = true
  }

  network {
    uuid = "${var.subnets[count.index % length(var.subnets)]}"
  }

  # this strange code safeguards from the strange format expected 
  # by OTC with tags
  # OTC can only hold 10 tags per instance
  tags = ["${formatlist("%.36s.%.43s", 
             split( "|", 
               replace( join("|", keys(var.tags)), 
                       local.tag_pattern, "_")),
             split( "|",
               replace( join("|",values(var.tags)),
                  local.tag_pattern, "-"))
          )}"]

  # TODO: since new OTC release, terraform cannot handle security group ids
  # properly and tries to recreate resources without change of sg
  lifecycle = {
    ignore_changes = ["ami", "kms_key_id", "security_group"]
  }

  //TODO: check iam_instance_profile   = "${var.iam_instance_profile}"
  //TODO: Unused yet: placement_group        = "${var.placement_group}"
  // TODO: implement additional structure in Terraform (not supported yet) 
  // not used for OTC: iops = "${var.ebs_root_volume_iops}"
  // }
}

// Create ebs volume is enable_encrypted_ebs is set to "true"
resource "opentelekomcloud_blockstorage_volume_v2" "ebs_volume" {
  count = "${var.attach_volume == "true" ? var.number_of_instances : 0 }"

  name              = "${opentelekomcloud_compute_instance_v2.ec2_instance.*.name[count.index]}-datadisk"
  availability_zone = "${opentelekomcloud_compute_instance_v2.ec2_instance.*.availability_zone[count.index]}"
  volume_type       = "${var.ebs_volume_type}"
  size              = "${var.ebs_volume_size}"

  # this strange code safeguards from the strange format expected 
  # by OTC with tags
  # OTC can only hold 10 tags per instance
  tags = "${zipmap( 
             split( "|",
               replace( join("|", keys(var.tags)), 
                  local.tag_pattern, "_")),
             split( "|", 
               replace( join("|",values(var.tags)),
                  local.tag_pattern, "-"))
          )}"

  //not used for OTC: iops              = "${var.ebs_volume_iops}"
  //TODO: kms_key_id  = "${var.enable_encrypted_ebs == "true" ? var.kms_key_id : "" }"
  //TODO: encrypted   = "${var.enable_encrypted_ebs}"
  lifecycle = {
    ignore_changes = ["kms_key_id"]
  }
}

locals {
  private_ips = "${opentelekomcloud_compute_instance_v2.ec2_instance.*.network.0.fixed_ip_v4}"
}

resource "opentelekomcloud_compute_volume_attach_v2" "ebs_att" {
  count = "${var.attach_volume == "true" ? var.number_of_instances : 0 }"

  //device      = "${var.ebs_device_name}"
  volume_id   = "${opentelekomcloud_blockstorage_volume_v2.ebs_volume.*.id[count.index]}"
  instance_id = "${opentelekomcloud_compute_instance_v2.ec2_instance.*.id[count.index]}"
}

###
# for simplicity, we do DNS entries static for the moment
# TODO: register DNS name in cloud-init on each boot of node dynamically
# deregister on shutdown
module "create-service-dns" {
  source = "../route53_record"

  num_entries   = "${var.number_of_instances}"
  dns_zone_name = "${var.tags["DOMAIN"]}"
  names         = ["${opentelekomcloud_compute_instance_v2.ec2_instance.*.name}"]
  ips           = ["${local.private_ips}"]

  // internal zones are scoped for dedicated VPCs. do not forget to add DNS
  // entries for management vpc!
  otc_zone_type = "private"

  otc_region   = "${var.otc_region}"
  otc_dns_vpcs = ["${var.otc_vpc}"]
  otc_token    = "${var.otc_token}"
}

###
# Post bootstrap preparations and chef registration
resource "null_resource" "post_bootstrap_disks" {
  count      = "${var.attach_volume == "true" ? var.number_of_instances : 0 }"
  depends_on = ["opentelekomcloud_compute_volume_attach_v2.ebs_att"]

  provisioner "remote-exec" {
    inline = [
      # Also better in baseimage
      # "sudo yum -y install nfs-utils",
      # "echo 'Installed NFS Utils'>>/tmp/init.log",
      "sudo mkdir /tempfiles",

      "${format("sudo cp -r %s/* /tempfiles/", var.ebs_mount_point)}",
      "${format("sudo mkdir -p %s", var.ebs_mount_point)}",
      "${format("sudo mkfs.ext4 %s",
                 opentelekomcloud_compute_volume_attach_v2.ebs_att.*.device[count.index])}",
      "${format("sudo mount -t ext4 %s %s",
                 opentelekomcloud_compute_volume_attach_v2.ebs_att.*.device[count.index], var.ebs_mount_point)}",
      "${format("sudo mv /tempfiles/* %s/", var.ebs_mount_point)}",
      "sudo rmdir /tempfiles",
      "${format("echo \"%s %s ext4 defaults 0 2\" | sudo tee --append /etc/fstab", opentelekomcloud_compute_volume_attach_v2.ebs_att.*.device[count.index], var.ebs_mount_point)}",
    ]
  }

  # TODO: post-destroy bootstrapping,login via ssh does not work yet
  # ((this should nnot be done anyway, so mid-term this should simply work
  #  with server sshutdown)
  # To still destroy servers during test, destroy pparts are commented out
  #
  #  provisioner "remote-exec" {
  #    when = "destroy"
  #
  #   inline = [
  #      // TODO: "${var.AMIIDQUERY == "BASEAMIRHEL7" ? "sudo systemctl stop sensu-client" : "sudo service sensu-client stop"}",
  #      "${format("sudo swapoff %s/swapfile", var.ebs_mount_point)}",
  #
  #      "${format("sudo umount %s -l || true", var.ebs_mount_point)}",
  #    ]
  #  }

  // Add swap memory
  provisioner "remote-exec" {
    inline = [
      "${format("sudo fallocate -l %sG %s/swapfile", var.swap_memory, var.ebs_mount_point)}",
      "${format("sudo chmod 0600 %s/swapfile", var.ebs_mount_point)}",
      "${format("sudo mkswap %s/swapfile", var.ebs_mount_point)}",
      "${format("sudo swapon %s/swapfile", var.ebs_mount_point)}",
      "${format("echo '%s/swapfile swap swap defaults 0 0' | sudo tee --append /etc/fstab", var.ebs_mount_point)}",
    ]
  }
  connection {
    type        = "ssh"
    user        = "${var.ec2_user}"
    host        = "${local.private_ips[count.index]}"
    private_key = "${file("${var.user_key}")}"
  }
}

# do some common preparations
resource "null_resource" "post_bootstrap_common" {
  count      = "${var.number_of_instances}"
  depends_on = ["null_resource.post_bootstrap_disks"]

  // Misc: change local and some other preparatzion, create
  provisioner "remote-exec" {
    inline = [
      "sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime",
      "sudo rm -f /etc/haproxy/00-haproxy.cfg",
      "echo 'consul ALL=(ALL) NOPASSWD: ALL' | sudo tee --append /etc/sudoers",
    ]

    # private servers should not install from internet;
    # moved these parts to baseimage creation
    #"sudo yum remove mariadb-libs mariadb-common mariadb-config -y",
    #"sudo yum install mysql -y",
  }

  connection {
    type        = "ssh"
    user        = "${var.ec2_user}"
    host        = "${local.private_ips[count.index]}"
    private_key = "${file("${var.user_key}")}"
  }
}

resource "null_resource" "post_bootstrap_service_user" {
  count      = "${(var.service_user!="_none_") ? var.number_of_instances : 0}"
  depends_on = ["null_resource.post_bootstrap_disks"]

  // Misc: change local and some other preparatzion, create
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/${var.service_user}",
      "sudo groupadd ${var.service_user}",
      "sudo useradd ${var.service_user} -g ${var.service_user} -d /home/${var.service_user}",
      "sudo chown ${var.service_user}:${var.service_user} /home/${var.service_user}",
    ]
  }

  connection {
    type        = "ssh"
    user        = "${var.ec2_user}"
    host        = "${local.private_ips[count.index]}"
    private_key = "${file("${var.user_key}")}"
  }
}

# separate knife call from siks actions to succeed or retry separately
resource "null_resource" "post_bootstrap_chef" {
  count      = "${var.number_of_instances}"
  depends_on = ["null_resource.post_bootstrap_disks"]

  #
  # The default provisioner should be prefered, but does not work
  # * it tries to install to contact terraform website, although install is
  #   disabled
  # * It cannot connect to internal chef server. It looks like the client
  #   need an additional port 443 open from pod to mgmt - which is not 
  #   what we want. Communication should only go from mgmt to pod on install
  # TODO switch to standard provisioner
  #provisioner "chef" {
  #  node_name       = "${format("%s-%d", var.instance_name, count.index+1)}"
  #  environment     = "${var.chef_env_name}"
  #  server_url      = "${var.chef_server_url}"
  #  #run_list        = ["${var.run_list}"]
  #  run_list        = [""]
  #  user_name       = "${var.chef_user}"
  #  user_key        = "${file(var.chef_user_key)}"
  #  ssl_verify_mode = ":verify_none" # TODO: enhance security, enable verify
  #  skip_install    = "true"
  #  recreate_client = "false"
  #}

  # Bootstrapping Chef client directly on chef server
  provisioner "local-exec" {
    command = "cd ${var.chef_repo_dir}; knife bootstrap ${local.private_ips[count.index]} --yes --server-url ${var.chef_server_url} --environment ${var.chef_env_name} --user ${var.chef_user} --key ${var.chef_user_key} --ssh-user ${var.ec2_user}  -i ${var.user_key} --sudo --node-name ${format("%s-%d", var.instance_name, count.index+1)} -V"
  }

  # TODO: Bootstrap during destroy does not work on OTC
  #
  #  provisioner "local-exec" {
  #    when    = "destroy"
  #    command = "cd ${var.chef_repo_dir};knife node delete ${format("%s-%d", var.instance_name, count.index+1)} --server-url ${var.chef_server_url}  --environment ${var.chef_env_name} --user ${var.chef_user} --key ${var.chef_user_key}"
  #    on_failure = "continue"  # continue even if unregistration fails
  #  }
}
