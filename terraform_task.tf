terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region     = "us-east-1"
  access_key = "#access_key#"
  secret_key = "#secret_key#"
}
# Vpc
resource "aws_vpc" "vpc_365" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default"
    tags = {
    Name = "vpc_365"
  }
}

# Internet gateway
resource "aws_internet_gateway" "IG_365" {
  vpc_id = aws_vpc.vpc_365.id
  tags = {
    Name = "IG_365"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_365.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public_subnet_365"
  }
}
# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc_365.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name        = "Private_Subnet_365"
  }
}

# Routing tables Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc_365.id

  tags = {
    Name        = "route for Private Subnet"
  }
}

# Routing tables Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_365.id

  tags = {
    Name        = "route for Public Subnet"
  }
}

# Security group allows ports 80 and 433
resource "aws_security_group" "sg_365" {
  name        = "sg_365"
  description = "sg_365"
  vpc_id      = aws_vpc.vpc_365.id

  egress  {
    description = "Allow port 443 from the internet"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [aws_vpc.vpc_365.cidr_block]
  }
  egress  {
    description = "Allow port 80 from the internet"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [aws_vpc.vpc_365.cidr_block]
  }
}

# ELB listening on ports 80 and 443
resource "aws_elb" "LB_365" {
  name = "elasticLB"
  availability_zones = ["us-east-1a", "us-east-1b"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id   = arn.aws_iam_server_certificate.pelegssl
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
}

# Create public certificate to LB
resource "aws_acm_certificate" "pelegssl" {
  domain_name       = "homeassignment.com"
  validation_method = "DNS"
}

# Create route 53 zone
resource "aws_route53_zone" "Routing_to_365" {
  name = "homeassignment.com"
  }

# Create aws_route53_record
resource "aws_route53_record" "elb_record" {
  zone_id = aws_route53_zone.Routing_to_365.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "elb"
  records        = ["elb.example.com"]
}