module "terraform_backend" {
  source = "github.com/padok-team/terraform-aws-terraformbackend?ref=0c51c6f1bdcab880c2f109d2aca08528e7032d2f"

  bucket_name         = "poc-vcb-terraform-state"
  dynamodb_table_name = "poc-vcb-terraform-lock"
}
