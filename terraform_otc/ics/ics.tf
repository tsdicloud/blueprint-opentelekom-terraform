// Dependency
terraform {
  required_version = "> 0.11.6"
}

module "create-ec2-terra" {
  source = "../service"

  AMIIDQUERY             = "${var.AMIIDQUERY}"
  latest_ami             = "${var.latest_ami}"
  ami_id                 = "${var.ami_id}"
  attach_volume          = "${var.attach_volume}"
  chef_server_url        = "${var.chef_server_url}"
  chef_env_name          = "${var.chef_env_name}"
  chef_repo_dir          = "${var.chef_repo_dir}"
  chef_user              = "${var.chef_user}"
  chef_user_key          = "${var.chef_user_key}"
  run_list               = "${var.run_list}"
  ebs_device_name        = ""                              //unused, module accepts system default device
  ebs_mount_point        = "${var.ebs_mount_point}"
  ebs_root_volume_iops   = ""                              // unused
  ebs_root_volume_size   = "${var.ebs_root_volume_size}"
  ebs_root_volume_type   = "${var.ebs_root_volume_type}"
  ebs_volume_iops        = ""                              // unused
  ebs_volume_size        = "${var.ebs_volume_size}"
  ebs_volume_type        = "${var.ebs_volume_type}"
  ec2_user               = "${var.ec2_user}"
  service_user           = "_none_"
  enable_encrypted_ebs   = "${var.enable_encrypted_ebs}"
  iam_instance_profile   = ""                              // unused
  instance_name          = "${var.instance_name}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  user_key               = "${var.user_key}"
  kms_key_id             = "${var.kms_key_id}"             // not used yet, forencrypted drives
  number_of_instances    = "${var.number_of_instances}"
  short_name             = "${var.short_name}"
  subnets                = "${var.subnets}"
  swap_memory            = "${var.swap_memory}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"

  otc_vpc    = "${var.otc_vpc}"
  otc_region = "${var.otc_region}"
  otc_azs    = "${var.otc_azs}"
  otc_token  = "${var.otc_token}"

  // NAME, Name and SHORT_HOSTNAME will be generated in runtime
  tags = "${var.tags}"
}

resource "null_resource" "terra_dedicated_config" {
  count = "${var.number_of_instances}"

  // Mount EFS Instance
  provisioner "remote-exec" {
    inline = [
      "if [[ ${var.mount_efs} == \"true\" ]]; then",
      "  sudo mkdir -p /data/shared_dir; echo \"${var.efs_ip_address}:/ /data/shared_dir nfs atime,diratime,rdirplus,vers=3,wsize=1048576,rsize=1048576,noacl,nocto,proto=tcp,async 0 0\" | sudo tee --append /etc/fstab;",
      "  sudo mount /data/shared_dir",
      "fi",
    ]
  }

  // Create User/Group, Folder Structure and Download Scripts
  provisioner "remote-exec" {
    inline = [
      "if [[ ! -d ${var.ebs_mount_point}/home/${var.terra_user} ]]; then",
      "  sudo mkdir -p ${var.ebs_mount_point}/home",
      "  sudo groupadd -g 502 ${var.terra_user}",
      "  sudo useradd -u 502 -g 502 -d ${var.ebs_mount_point}/home/${var.terra_user} ${var.terra_user}",
      "fi",
      "if [[ ! -d /data/shared_dir/downloads ]]; then",
      "  sudo mkdir -p /data/shared_dir/downloads",
      "  for i in atlantic customdbs-dir downloads dqdata error-logs mapgen-dir packages packages-temp pcsxml repo_dumps; do sudo mkdir -p /data/shared_dir/$i; done",
      "  sudo mkdir -p /data/shared_dir/atlantic/dbData",
      "  sudo mkdir -p /data/shared_dir/atlantic/uploadedFiles",
      "  sudo mkdir -p /data/shared_dir/packages/linux64/package",
      "  sudo mkdir -p /data/shared_dir/packages/win64/package",
      "  sudo mkdir -p /data/shared_dir/appshare/mapgen_dir",
      "  sudo mkdir -p /data/shared_dir/appshare/agent-packages/win64/package",
      "  sudo mkdir -p /data/shared_dir/appshare/agent-packages/linux64/package",
      "  sudo chown -R ${var.terra_user}:${var.terra_user} /data/shared_dir",
      "fi",
    ]
  }

  connection {
    type        = "ssh"
    user        = "${var.ec2_user}"
    host        = "${module.create-ec2-terra.ec2_instance_private_ip[count.index]}"
    private_key = "${file("${var.user_key}")}"
  }
}
