provider "boundary" {
  addr             = "http://127.0.0.1:9200"
  recovery_kms_hcl = <<EOT
kms "awskms" {
  purpose    = "recovery"
  region = "eu-west-3"
  kms_key_id = "${data.terraform_remote_state.backbone.outputs.kms_id}"
}
EOT
}

