# Get a list of all available AZs in the current region
data "aws_availability_zones" "available" {}

# Create a VPC with public and private subnets using the AWS VPC community module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = var.name
  cidr = var.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  private_subnets = slice(var.private_cidrs, 0, var.az_count)
  public_subnets  = slice(var.public_cidrs, 0, var.az_count)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

# Tagging subnets so Kubernetes knows which ones to use for LoadBalancers
  public_subnet_tags  = { 
    "kubernetes.io/role/elb" = "1" 
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  private_subnet_tags = { 
    "kubernetes.io/role/internal-elb" = "1" 
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }

  tags = var.tags
}