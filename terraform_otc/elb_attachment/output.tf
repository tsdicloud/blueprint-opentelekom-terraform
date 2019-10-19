output "elb_id" {
  value = "${opentelekomcloud_elb_loadbalancer.elb.id}"
}

output "elb_name" {
  value = "${opentelekomcloud_elb_loadbalancer.elb.name}"
}

//TODO: assign the loadbalancer an DNS name (not done automatically
//      on OTC
//output "elb_dns_name" {
//  value = "${otc_elb.elb.dns_name}"
//}

