locals {
  POD            = "${lower(var.POD)}"
  APPLICATIONENV = "${lower(var.APPLICATIONENV)}"
  BUSINESSUNIT   = "${lower(var.BUSINESSUNIT)}"

  tmpl_vars = {
    POD            = "${local.POD}"
    APPLICATIONENV = "${local.APPLICATIONENV}"
    BUSINESSUNIT   = "$|local.BUSINESSUNIT}"
    DOMAIN         = "${var.DOMAIN}"
    ma_url         = "$|var.ma_url}"
    pod_url        = "${var.pod_url}"
    root_cert_dir  = "${var.root_cert_dir}"
    haproxy_key    = "${var.haproxy_key}"
    podprefix      = "${var.podprefix}"

    int_haproxy_key = "${var.int_haproxy_key}"
    package_url     = "${var.tsys_package_url}"
    cdnURL          = "${var.cdnURL}"
    ipfilter        = "${var.ipfilter}"

    tsys_package_url    = "${var.tsys_package_url}"
    tsys_key_password   = "${var.tsys_key_password}"
    tsys_trust_password = "${var.tsys_trust_password}"
  }
}

data "template_file" "kafka_env" {
  vars     = "${local.tmpl_vars}"
  template = "${file("${path.module}/chef-env-tmpl/chef-env-kafka.json")}"
}

resource "local_file" "kafka_file" {
  content  = "${data.template_file.kafka_env.rendered}"
  filename = "${var.chef_repo_dir}/environments/${var.podprefix}-kafka.json"

  provisioner "local-exec" {
    command = "knife environment from file ${var.chef_repo_dir}/environments/${var.podprefix}-kafka.json --server-url ${var.chef_server_url} --user ${var.chef_user} --key ${var.chef_user_key}"
  }
}

data "template_file" "ext-haproxy_env" {
  vars     = "${local.tmpl_vars}"
  template = "${file("${path.module}/chef-env-tmpl/chef-env-ext-haproxy.json")}"
}

resource "local_file" "ext-haproxy_file" {
  content  = "${data.template_file.ext-haproxy_env.rendered}"
  filename = "${var.chef_repo_dir}/environments/${var.podprefix}-ext-haproxy.json"

  provisioner "local-exec" {
    command = "knife environment from file ${var.chef_repo_dir}/environments/${var.podprefix}-ext-haproxy.json --server-url ${var.chef_server_url} --user ${var.chef_user} --key ${var.chef_user_key}"
  }
}

data "template_file" "int-haproxy_env" {
  vars     = "${local.tmpl_vars}"
  template = "${file("${path.module}/chef-env-tmpl/chef-env-int-haproxy.json")}"
}

resource "local_file" "int-haproxy_file" {
  content  = "${data.template_file.int-haproxy_env.rendered}"
  filename = "${var.chef_repo_dir}/environments/${var.podprefix}-int-haproxy.json"

  provisioner "local-exec" {
    command = "knife environment from file ${var.chef_repo_dir}/environments/${var.podprefix}-int-haproxy.json --server-url ${var.chef_server_url} --user ${var.chef_user} --key ${var.chef_user_key}"
  }
}

data "template_file" "ma-haproxy_env" {
  vars     = "${local.tmpl_vars}"
  template = "${file("${path.module}/chef-env-tmpl/chef-env-ma-haproxy.json")}"
}

resource "local_file" "ma-haproxy_file" {
  content  = "${data.template_file.ma-haproxy_env.rendered}"
  filename = "${var.chef_repo_dir}/environments/${var.podprefix}-ma-haproxy.json"

  provisioner "local-exec" {
    command = "knife environment from file ${var.chef_repo_dir}/environments/${var.podprefix}-ma-haproxy.json --server-url ${var.chef_server_url} --user ${var.chef_user} --key ${var.chef_user_key}"
  }
}

data "template_file" "ma_env" {
  vars     = "${local.tmpl_vars}"
  template = "${file("${path.module}/chef-env-tmpl/chef-env-ma.json")}"
}

resource "local_file" "ma_file" {
  content  = "${data.template_file.ma_env.rendered}"
  filename = "${var.chef_repo_dir}/environments/${var.podprefix}-ma.json"

  provisioner "local-exec" {
    command = "knife environment from file ${var.chef_repo_dir}/environments/${var.podprefix}-ma.json --server-url ${var.chef_server_url} --user ${var.chef_user} --key ${var.chef_user_key}"
  }
}

data "template_file" "services_env" {
  vars     = "${local.tmpl_vars}"
  template = "${file("${path.module}/chef-env-tmpl/chef-env-services.json")}"
}

resource "local_file" "services_file" {
  content  = "${data.template_file.services_env.rendered}"
  filename = "${var.chef_repo_dir}/environments/${var.podprefix}-services.json"

  provisioner "local-exec" {
    command = "knife environment from file ${var.chef_repo_dir}/environments/${var.podprefix}-services.json --server-url ${var.chef_server_url} --user ${var.chef_user} --key ${var.chef_user_key}"
  }
}

resource "null_resource" "chef-repo" {
  # repo should be checked in later to git
  provisioner "local-exec" {
    command = "chef generate repo ${var.chef_repo_dir}"
  }

  # get trusted certificates directly after repo generation
  provisioner "local-exec" {
    command = "cd ${var.chef_repo_dir};knife ssl fetch"
  }

  # upload all cookbooks from local dir
  provisioner "local-exec" {
    command = "knife cookbook upload --server-url ${var.chef_server_url} --user ${var.chef_user} --key ${var.chef_user_key} --cookbook-path ${var.chef_repo_dir}/cookbooks/ --include-dependencies -a"
  }
}
