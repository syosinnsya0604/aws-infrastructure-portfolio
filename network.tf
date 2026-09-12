resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aws-infra-portfolio-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-infra-portfolio-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-infra-portfolio-public-1c"
  }
}

resource "aws_subnet" "app_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "aws-infra-portfolio-app-1a"
  }
}

resource "aws_subnet" "app_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "aws-infra-portfolio-app-1c"
  }
}

resource "aws_subnet" "db_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "aws-infra-portfolio-db-1a"
  }
}

resource "aws_subnet" "db_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "aws-infra-portfolio-db-1c"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "aws-infra-portfolio-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "aws-infra-portfolio-public-rt"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "aws-infra-portfolio-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "aws-infra-portfolio-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "aws-infra-portfolio-app-private-rt"
  }
}

resource "aws_route_table_association" "app_1a" {
  subnet_id      = aws_subnet.app_1a.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "app_1c" {
  subnet_id      = aws_subnet.app_1c.id
  route_table_id = aws_route_table.app_private.id
}