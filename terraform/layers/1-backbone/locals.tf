locals {
  name                         = "poc-vcb"
  env                          = "test"
  region                       = "eu-west-3"
  domain_name                  = "padok.school"
  boundary_api_domain_name     = "boundary-api.${local.domain_name}"
  boundary_cluster_domain_name = "boundary-cluster.${local.domain_name}"
  boundary_worker_domain_name  = "boundary-worker.${local.domain_name}"
  target_group_port            = "80"
  target_group_protocol        = "HTTP"
  project                      = "padok_lab"
  vpc_id                       = "vpc-xxxxxx"
  vpc_private_subnets_ids      = ["subnet-xxxxxx","subnet-xxxxxx"]
  node_group_iam_role_name     = "app-eks-node-group-xxxxxx"
}
