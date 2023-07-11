terraform {
  backend "s3" {
    profile        = "padok_lab"
    dynamodb_table = "poc-vcb-terraform-lock"
    bucket         = "poc-vcb-terraform-backend"
    key            = "vault/tfstate.json"
    region         = "eu-west-3"
  }
}
