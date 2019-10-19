output "kms_key_id" {
  value = "${opentelekomcloud_kms_key_v1.create_kms_key.id}"
}

// At the time of the first port, arn is not used anywhere in the
// terraform code. Output is not available on OTC and thus disabled. 
//output "arn" {
//  value = "${opentelekomcloud_kms_key_v1.create_kms_key.*.key_id}"
//}

