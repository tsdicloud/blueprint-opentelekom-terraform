locals {
  key_dir   = "${var.base_dir}/keys"
  trust_dir = "${var.base_dir}/certs"
}

resource "null_resource" "refresh-ca" {
  provisioner "local-exec" {
    command = <<CA
      ${path.module}/refresh-ca.sh \
      --name ${var.ca_basename} \
      --suffix ${var.ca_label} \
      --trust-password ${var.trust_password} \
      --root-type ${var.root_type} \
      --root-days ${var.root_days} \
      --inter-type ${var.inter_type} \
      --inter-days ${var.inter_days} \
      --key-dir ${local.key_dir} \
      --trust-dir ${local.trust_dir}
CA
  }
}

resource "null_resource" "refresh-kafka-certs" {
  count = "${length(var.num_kafka)}"

  triggers {
    root_ca_changed  = "${null_resource.refresh-ca.id}"
    services_changed = "${join(";", formatlist("%s:%s", keys(var.haproxies), values(var.haproxies)))}"
  }

  provisioner "local-exec" {
    command = <<CERT
      ${path.module}/refresh-cert.sh \
      --suffix ${var.ca_label} \
      --trust-password ${var.trust_password} \
      --key-type ${var.key_type} \
      --key-days ${var.key_days} \
      --key-dir ${local.key_dir} \
      --key-password ${var.trust_password} \
      --trust-dir ${local.trust_dir} \
      --trust-password ${var.trust_password} \
      --root_cert_dir ${var.root_cert_dir} \
      --cert-user kafka \
      --ssh-user ${var.ec2_user} \
      --ssh-key ${var.user_key} \
      --host-ip ${element(split("=", element(values(var.kafka), count.index)),0)} \
      --host ${element(keys(var.kafka), count.index)} \
      --services '${element(split("=", element(values(var.kafka), count.index)),1)}'
CERT
  }
}

resource "null_resource" "refresh-haproxy-certs" {
  count = "${length(var.num_haproxies)}"

  triggers {
    root_ca_changed  = "${null_resource.refresh-ca.id}"
    services_changed = "${join(";", formatlist("%s:%s", keys(var.haproxies), values(var.haproxies)))}"
  }

  provisioner "local-exec" {
    command = <<CERT
      ${path.module}/refresh-cert.sh \
      --suffix ${var.ca_label} \
      --trust-password ${var.trust_password} \
      --key-type ${var.key_type} \
      --key-days ${var.key_days} \
      --key-dir ${local.key_dir} \
      --key-password ${var.trust_password} \
      --trust-dir ${local.trust_dir} \
      --trust-password ${var.trust_password} \
      --root_cert_dir ${var.root_cert_dir} \
      --cert-user haproxy \
      --ssh-user ${var.ec2_user} \
      --ssh-key ${var.user_key} \
      --host-ip ${element(split("=", element(values(var.haproxies), count.index)),0)} \
      --host ${element(keys(var.haproxies), count.index)}
CERT
  }
}

resource "null_resource" "refresh-saas-certs" {
  count = "${length(var.num_saas)}"

  triggers {
    root_ca_changed  = "${null_resource.refresh-ca.id}"
    services_changed = "${join(";", formatlist("%s:%s", keys(var.saas), values(var.saas)))}"
  }

  provisioner "local-exec" {
    command = <<CERT
      ${path.module}/refresh-cert.sh \
      --suffix ${var.ca_label} \
      --trust-password ${var.trust_password} \
      --key-type ${var.key_type} \
      --key-days ${var.key_days} \
      --key-dir ${local.key_dir} \
      --key-password ${var.trust_password} \
      --trust-dir ${local.trust_dir} \
      --trust-password ${var.trust_password} \
      --root_cert_dir ${var.root_cert_dir} \
      --cert-user saasqa \
      --ssh-user ${var.ec2_user} \
      --ssh-key ${var.user_key} \
      --host-ip ${element(split("=", element(values(var.saas), count.index)),0)} \
      --host ${element(keys(var.saas), count.index)} \
      --services '${element(split("=", element(values(var.saas), count.index)),1)}'
CERT
  }
}

resource "null_resource" "refresh-service-certs" {
  count = "${length(var.num_services)}"

  triggers {
    root_ca_changed  = "${null_resource.refresh-ca.id}"
    services_changed = "${join(";", formatlist("%s:%s", keys(var.services), values(var.services)))}"
  }

  provisioner "local-exec" {
    command = <<CERT
      ${path.module}/refresh-cert.sh \
      --suffix ${var.ca_label} \
      --trust-password ${var.trust_password} \
      --key-type ${var.key_type} \
      --key-days ${var.key_days} \
      --key-dir ${local.key_dir} \
      --key-password ${var.trust_password} \
      --trust-dir ${local.trust_dir} \
      --trust-password ${var.trust_password} \
      --root_cert_dir ${var.root_cert_dir} \
      --cert-user tomcat \
      --ssh-user ${var.ec2_user} \
      --ssh-key ${var.user_key} \
      --host-ip ${element(split("=", element(values(var.services), count.index)),0)} \
      --host ${element(keys(var.services), count.index)} \
      --services '${element(split("=", element(values(var.services), count.index)),1)}'
CERT
  }
}
