resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3a"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)

  map_public_ip_on_launch = true

  tags = {
    Name = "boundary-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3b"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)

  map_public_ip_on_launch = true

  tags = {
    Name = "boundary-2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for subnet in [aws_subnet.public_1, aws_subnet.public_2] :
    subnet.tags.Name => subnet
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
