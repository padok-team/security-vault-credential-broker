terraform {
  backend "s3" {
    profile        = "padok_univ_2"
    dynamodb_table = "poc-vcb-lib-terraform-lock"
    bucket         = "poc-vcb-lib-terraform-state"
    key            = "boundary/tfstate.json"
    region         = "eu-west-3"
  }
}
