data "terraform_remote_state" "backbone" {
  backend = "s3"

  config = {
    bucket  = "poc-vcb-terraform-state"
    key     = "backbone/tfstate.json"
    region  = "eu-west-3"
    profile = "padok_lab"
  }
}
