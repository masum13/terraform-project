provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
    }
  }
}

terraform {
  backend "s3" {
    bucket  = var.tfstate_bucket
    encrypt = false
    key     = "credencys/terraform.tfstate"
    region  = var.region
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.vpc_tags
}

// Public subnet

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.availability_zones[0]
  cidr_block              = var.public_subnet_1_cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "${var.environment}-${var.project}-public-subnet-01"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.availability_zones[1]
  cidr_block              = var.public_subnet_2_cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "${var.environment}-${var.project}-public-subnet-02"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.availability_zones[2]
  cidr_block              = "10.120.2.0/25"
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "${var.environment}-${var.project}-public-subnet-03"
  }
}

// Private subnet

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.this.id
  availability_zone = var.availability_zones[0]
  cidr_block        = var.private_subnet_1_cidr
  tags = {
    Name = "${var.environment}-${var.project}-private-subnet-01"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.this.id
  availability_zone = var.availability_zones[1]
  cidr_block        = var.private_subnet_2_cidr
  tags = {
    Name = "${var.environment}-${var.project}-private-subnet-02"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.this.id
  availability_zone = var.availability_zones[2]
  cidr_block        = var.private_subnet_3_cidr
  tags = {
    Name = "${var.environment}-${var.project}-private-subnet-03"
  }
}

// IG

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.this.id
  tags   = var.IG_tags
}

// EIP

resource "aws_eip" "elastic_ip_for_nat_gw" {
  vpc        = true
  depends_on = [aws_internet_gateway.IGW]
  tags = {
    Name = "${var.environment}-${var.project}-natgateway-eip"
  }
}

// NAT

resource "aws_nat_gateway" "NATGW" {
  allocation_id = aws_eip.elastic_ip_for_nat_gw.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags          = var.NATGW_tags
  depends_on = [
    aws_eip.elastic_ip_for_nat_gw
  ]
}

// Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.environment}-${var.project}-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.environment}-${var.project}-private-route-table"
  }
}

// Route table association for subnets

resource "aws_route_table_association" "public-route-1-association" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "public-route-2-association" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

resource "aws_route_table_association" "public-route-3-association" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnet_3.id
}

resource "aws_route_table_association" "private-route-1-association" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_subnet_1.id
}

resource "aws_route_table_association" "private-route-2-association" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_subnet_2.id
}

resource "aws_route_table_association" "private-route-3-association" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_subnet_3.id
}

# IGW route
resource "aws_route" "internet_igw_route" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.IGW.id
  destination_cidr_block = "0.0.0.0/0"
}

# NATGW route
resource "aws_route" "nat_gw_route" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.NATGW.id
  destination_cidr_block = "0.0.0.0/0"
}

# Security Groups 

resource "aws_security_group" "ecs_sg" {
  name   = "${var.environment}-${var.project}-ecs-sg"
  vpc_id = aws_vpc.this.id

  ingress {
      from_port        =  8080
      to_port          =  8080
      protocol         =  "TCP"
      description      =  "Allow inbound access from ALB sg"
      security_groups  =  aws_security_group.alb_sg.id
  }

  dynamic "ingress" {
    for_each = var.sg_ecs_ingress
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = lookup(ingress.value, "protocol", null)
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      description      = lookup(ingress.value, "description", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
      self             = lookup(ingress.value, "self", null)
    }
  }

  egress {
      from_port        =  8080
      to_port          =  8080
      protocol         =  "TCP"
      description      =  "Allow outbound access to ALB sg"
      security_groups  =  aws_security_group.alb_sg.id
  }

  dynamic "egress" {
    for_each = var.sg_ecs_egress
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = lookup(egress.value, "protocol", null)
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      description      = lookup(egress.value, "description", null)
      security_groups  = lookup(egress.value, "security_groups", null)
      self             = lookup(egress.value, "self", null)
    }
  }
  tags = merge({ Name = "${var.environment}-${var.project}-ecs-sg" }, var.ecs_sg_tags)

  lifecycle {
    ignore_changes = [ingress]
  }
}


resource "aws_security_group" "alb_sg" {
  name   = "${var.environment}-${var.project}-ecs-sg"
  vpc_id = aws_vpc.this.id
  
  dynamic "ingress" {
    for_each = var.sg_ecs_ingress
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = lookup(ingress.value, "protocol", null)
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      description      = lookup(ingress.value, "description", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
      self             = lookup(ingress.value, "self", null)
    }
  }

  dynamic "egress" {
    for_each = var.sg_ecs_egress
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = lookup(egress.value, "protocol", null)
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      description      = lookup(egress.value, "description", null)
      security_groups  = lookup(egress.value, "security_groups", null)
      self             = lookup(egress.value, "self", null)
    }
  }
  tags = merge({ Name = "${var.environment}-${var.project}-ecs-sg" }, var.ecs_sg_tags)

  lifecycle {
    ignore_changes = [ingress]
  }
}