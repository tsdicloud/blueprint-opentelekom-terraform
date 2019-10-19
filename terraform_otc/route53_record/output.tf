output "route53_name" {
  value = ["${local.dns_names}"]
}

#output "route53_records" {
#  value = ["${opentelekomcloud_dns_recordset_v2.record.*.id}"]
#}

