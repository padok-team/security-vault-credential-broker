locals {
  name                         = "boundary-eks"
  env                          = "test"
  region                       = "eu-west-3"
  domain_name                  = "padok.school"
  boundary_api_domain_name     = "boundary-api.${local.domain_name}"
  boundary_cluster_domain_name = "boundary-cluster.${local.domain_name}"
  boundary_worker_domain_name  = "boundary-worker.${local.domain_name}"
  target_group_port            = "80"
  target_group_protocol        = "HTTP"
  project                      = "padok_lab"
}
