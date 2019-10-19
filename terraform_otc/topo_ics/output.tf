// Output the ID of the EC2 instance created
output "ec2_instance_id" {
  value = ["${module.create-topo-terra.ec2_instance_id}"]
}

output "ec2_instance_private_ip" {
  value = ["${module.create-topo-terra.ec2_instance_private_ip}"]
}

output "ec2_instance_private_names" {
  value = ["${module.create-topo-terra.ec2_instance_private_names}"]
}

output "number_of_instances" {
  value = "${local.number_of_instances}"
}

output "run_list" {
  value = ["${local.run_list}"]
}

output "masterstate" {
  value = "${formatlist("{$%s} = @TERRAnode,%s", module.create-topo-terra.ec2_instance_private_ip, local.contents)}"
}

output "cert_targets" {
  value = "${zipmap(module.create-topo-terra.ec2_instance_private_names, formatlist("%s=%s", module.create-topo-terra.ec2_instance_private_ip, local.services))}"
}
