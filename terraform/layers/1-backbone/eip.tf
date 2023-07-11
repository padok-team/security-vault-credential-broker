resource "aws_eip" "controller-1" {
  domain = "vpc"
  tags = {
    Name = "${local.name}-boundary-controller-1"
  }
}

resource "aws_eip" "controller-2" {
  domain = "vpc"
  tags = {
    Name = "${local.name}-boundary-controller-2"
  }
}

resource "aws_eip" "worker-1" {
  domain = "vpc"
  tags = {
    Name = "${local.name}-boundary-worker-1"
  }
}

resource "aws_eip" "worker-2" {
  domain = "vpc"
  tags = {
    Name = "${local.name}-boundary-worker-2"
  }
}