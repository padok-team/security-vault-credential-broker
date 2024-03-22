# To be applied after the main layer

data "aws_lb" "nlb-boundary-cluster" {
  tags = {
    "kubernetes.io/cluster/${local.name}" : "owned",
    "kubernetes.io/service-name" : "boundary/boundary-controller-cluster"
  }
}

data "aws_lb" "nlb-boundary-worker" {
  tags = {
    "kubernetes.io/cluster/${local.name}" : "owned",
    "kubernetes.io/service-name" : "boundary/boundary-worker"
  }
}

data "aws_lb" "nlb-boundary-api" {
  tags = {
    "kubernetes.io/cluster/${local.name}" : "owned",
    "kubernetes.io/service-name" : "boundary/boundary-controller-api"
  }
}

data "aws_elb" "lb-vault" {
  name = "xxxxxx"
}


data "aws_route53_zone" "this" {
  name = local.domain_name
}

resource "aws_route53_record" "boundary-cluster" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.boundary_cluster_domain_name
  type    = "A"
  alias {
    name                   = data.aws_lb.nlb-boundary-cluster.dns_name 
    zone_id                = data.aws_lb.nlb-boundary-cluster.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "boundary-worker" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.boundary_worker_domain_name
  type    = "A"
  alias {
    name                   = data.aws_lb.nlb-boundary-worker.dns_name 
    zone_id                = data.aws_lb.nlb-boundary-worker.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "boundary-api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.boundary_api_domain_name
  type    = "A"
  alias {
    name                   = data.aws_lb.nlb-boundary-api.dns_name 
    zone_id                = data.aws_lb.nlb-boundary-api.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.vault_domain_name
  type    = "A"
  alias {
    name                   = data.aws_elb.lb-vault.dns_name 
    zone_id                = data.aws_elb.lb-vault.zone_id
    evaluate_target_health = true
  }
}