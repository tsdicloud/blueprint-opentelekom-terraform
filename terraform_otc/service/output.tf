// Output the ID of the EC2 instance created
output "ec2_instance_id" {
  value = ["${opentelekomcloud_compute_instance_v2.ec2_instance.*.id}"]
}

output "ec2_instance_private_ip" {
  value = ["${local.private_ips}"]
}

output "ec2_instance_private_names" {
  value = ["${module.create-service-dns.route53_name}"]
}
