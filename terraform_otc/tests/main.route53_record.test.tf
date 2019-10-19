module "create_route53_record" {
  source = "../route53_record"

  name          = "testdummy"
  ips           = ["10.20.198.158"]
  dns_zone_name = "doaascloud-internal.net"

  // internal zones are scoped for dedicated VPCs. do not forget to add DNS
  // entries for management vpc!
  otc_region = "${var.otc_region}"

  otc_dns_vpcs = ["d63bdd29-cba8-4914-aabf-2e4ce50e97f0", "26bd29ff-c60f-43c8-917a-eb598d26d0b2"]
}
