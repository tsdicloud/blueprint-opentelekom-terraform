// Output the ID of the EC2 instance created
output "ec2_instance_id" {
  value = ["${module.create-ec2-terra.ec2_instance_id}"]
}

output "ec2_instance_private_ip" {
  value = ["${module.create-ec2-terra.ec2_instance_private_ip}"]
}

output "ec2_instance_private_names" {
  value = ["${module.create-ec2-terra.ec2_instance_private_names}"]
}
