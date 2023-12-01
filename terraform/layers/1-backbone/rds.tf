module "rds" {
  source = "../../module/rds"

  providers = {
    aws = aws
  }

  ## GENERAL
  identifier = local.name

  ## DATABASE
  engine              = "postgres"
  engine_version      = "13.7"
  db_parameter_family = "postgres13"
  name                = "aws_rds_instance_postgresql_db_poc_vcb"
  username            = "aws_rds_instance_postgresql_user_poc_vcb"

  parameters = [{
    name         = "application_name"
    value        = "mydb"
    apply_method = "immediate"
    },
    {
      name         = "rds.rds_superuser_reserved_connections"
      value        = 4
      apply_method = "pending-reboot"
  }]

  ## NETWORK
  subnet_ids         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  vpc_id             = aws_vpc.main.id
  security_group_ids = [aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
}

data "aws_security_groups" "eks-node" {
  filter {
    name   = "group-name"
    values = ["${local.name}-node*"]
  }

  tags = {
    "kubernetes.io/cluster/${local.name}" = "owned"
  }
}
