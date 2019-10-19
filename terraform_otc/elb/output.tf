output "elb_id" {
  // OTC needs the listener id, not the loadbalancer id; 
  // thhs is what we pass on in elb_id
  value = ["${local.elb_ids}"]
}

output "elb_name" {
  value = ["${local.elb_names}"]
}

//TODO: assign the loadbalancer an DNS name (not done automatically
//      on OTC
//output "elb_dns_name" {
//  value = "${otc_elb.elb.dns_name}"
//}

