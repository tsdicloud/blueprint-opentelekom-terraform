module "create-kms-key" {
  //source = "git@github.com:infacloud/florence-infra.git//terraform/kms_key?ref=master"
  source = "../kms_key"

  alias       = "doaas-dummy-encryption-key"
  description = "DOaaS dummy Encryption key"

  tags = {
    businessunit = "doaas"
    name         = "doaas-pod1-encryption-key"
    owneremail   = "tim.busch@t-systems.com"
  }
}
