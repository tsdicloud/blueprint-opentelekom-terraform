# terraform can neither handle OTC nor AWS zone case properly
# Behavior to model is: Keep the zone entries as soon as they are requested, keep the zones infinetly
# rebuild zone if it does not exist. The native API call approach is currently the only option.

# ask OpenTelekomCLoud directly for the id of the now-existing zone
# TODO: may implement this as the default behavior of a new terraform
# dns zone provider or add flags like force_destroy to existing and 
# do not fail if create OTC call fails
data "external" "assert_zone_exist" {
  program = ["${path.module}/assert_zone_exist.sh",
    "--os-region",
    "${var.otc_region}",
    "--type",
    "${var.otc_zone_type}",
    "--vpc",
    "${var.otc_dns_vpcs[0]}",
    "--zone",
    "${var.dns_zone_name}",
    "--os-token",
    "${var.otc_token}",
  ]
}

#resource "opentelekomcloud_dns_zone_v2" "zone" {
#  count = "${data.external.zone_exist.result.id != "" ? 1 : 0 }"
#
#  name  = "${var.dns_zone_name}."
#  #email = "test@t-systems.com"
#  #description = "ITERRA pod zone"
#  type = "${var.otc_zone_type}"
#
#  router = {
#    router_id     = "${var.otc_dns_vpcs[0]}"
#    router_region = "${var.otc_region}"
#  }
#
#  lifecycle {
#    ignore_changes = ["router", "id"]
#  }
#}

locals {
  chunk_divider = "${var.num_entries>0 ? var.num_entries : 1 }"
  suffixed_ips  = "${formatlist("%s.",var.ips)}"
  chunked_ips   = "${chunklist(local.suffixed_ips, 
        length(local.suffixed_ips)/local.chunk_divider)}"
}

resource "opentelekomcloud_dns_recordset_v2" "record" {
  count   = "${var.num_entries}"
  region  = "${var.otc_region}"
  type    = "CNAME"
  zone_id = "${data.external.assert_zone_exist.result.id}"
  name    = "${lower(var.names[count.index])}.${lower(var.dns_zone_name)}."
  records = ["${local.chunked_ips[count.index]}"]
  ttl     = "900"

  lifecycle {
    ignore_changes = ["id"]
  }
}

locals {
  # Terraform weakness again: remove suffix . from each dns list entry
  dns_joined = "${join("|", opentelekomcloud_dns_recordset_v2.record.*.name)}"
  dns_cutend = "${substr(local.dns_joined, 0, length(local.dns_joined)-1)}"
  dns_names  = "${compact(split(".|", local.dns_cutend))}"
}
