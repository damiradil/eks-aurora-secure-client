# KMS key to encrypt secrets at rest in EKS
resource "aws_kms_key" "eks_secrets" {
  description             = "EKS secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

# User-friendly alias for the KMS key
resource "aws_kms_alias" "eks_secrets_alias" {
  name          = "alias/${var.cluster_name}-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

# EKS cluster using the official terraform-aws-modules/eks/aws module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.16"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids

  cluster_endpoint_public_access  = var.public_access
  cluster_endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

  # Encrypt k8s Secrets with KMS
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = aws_kms_key.eks_secrets.arn
  }

   # Node groups
  eks_managed_node_groups = {
    # System node group: 1 small on-demand instance, always running
    sys = {
      name           = "sys"
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      subnet_ids     = var.subnet_ids
      tags           = merge(var.tags, { Workload = "system" })
    }

    # Application node group: spot instances, scales from 0→1 when workloads run
    app = {
      name           = "app"
      desired_size   = 0
      min_size       = 0
      max_size       = 1
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      subnet_ids     = var.subnet_ids
      tags           = merge(var.tags, { Workload = "application" })
    }
  }

  # Core EKS addons
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  tags = var.tags
}