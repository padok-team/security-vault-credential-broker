provider "aws" {
  region = local.region
  profile = local.project
}

provider "dns" {
  update {
    server = "1.1.1.1"
  }
}