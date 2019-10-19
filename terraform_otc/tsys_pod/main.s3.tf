#####
# NOTE: The terraform OpenTelekomCloud provider for objectstore resources
# cloud be "overrun" by multiple parallel uploads and produce errors about
# not finding the object with the corresponding od any more.
#
# In this case, simply rerun the provider for the remaining ressources.
# Due to the "all or nothing" upload semantterra of ObjectStore/S3, any
# failing upload will retried.
#

#locals {
#  podprefix = "${lower(var.BUSINESSUNIT)}-${lower(var.APPLICATIONENV)}-${lower(var.POD)}"
#}

###
# Create an S3 bucket for Java code repo
#
resource "opentelekomcloud_s3_bucket" "code_bucket" {
  bucket = "${var.tsys_code_bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

###
# Restrict with a policy for anonymous, but local access only
# TODO: may enforce secuirty for code and may encrypt bucket
#
#locals {
#  distinct_ips = "${distinct(list(var.cidr_blocks_pod, var.cidr_blocks_ma, var.cidr_blocks_mgmt))}"
#  internal_ips = "${join(",",formatlist("\"%s\"", local.distinct_ips)) }"
#}

# restrict to internal ips and and mgmt IPs
# TODO: find better secure access to files without setup of another server
# keep cheap storage for 2GB package data
resource "opentelekomcloud_s3_bucket_policy" "code_policy" {
  bucket = "${opentelekomcloud_s3_bucket.code_bucket.id}"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "${local.podprefix}-bucketpolicy",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject","s3:GetObjectVersion"],
      "Resource": "arn:otc:s3:::${var.tsys_code_bucket_name}/*",
      "Condition": {
         # only allow access from internal OBS Gateway
         "IpAddress": {"otc:SourceIp": [ "100.72.10.138/24" ] }
      } 
    } 
  ]
}
POLICY
}

###
# Upload current code
#
data "external" "packages" {
  # find all entries in dir, deliver as one-field json 
  program = ["./tsys_package_list.sh", "${var.tsys_code_localdir}"]
}

locals {
  packages = "${split(" ", replace(data.external.packages.result.files, "./", ""))}"
}

resource "opentelekomcloud_s3_bucket_object" "object" {
  depends_on = ["opentelekomcloud_s3_bucket_policy.code_policy"]
  count      = "${data.external.packages.result.count}"
  bucket     = "${var.tsys_code_bucket_name}"
  key        = "${local.packages[count.index]}"
  source     = "${var.tsys_code_localdir}/${local.packages[count.index]}"
}
