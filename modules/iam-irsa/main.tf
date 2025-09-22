# Reference the existing EKS OIDC provider (created by the EKS module)
data "aws_iam_openid_connect_provider" "this" {
  arn = var.oidc_provider_arn
}

# Local values used to build conditions for the trust policy
locals {
  oidc_hostpath = replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")
  sa_sub        = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}

# IAM role to be assumed by the Kubernetes ServiceAccount via IRSA
resource "aws_iam_role" "this" {
  name               = coalesce(var.role_name, "irsa-${var.namespace}-${var.service_account_name}")
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Federated = var.oidc_provider_arn },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${local.oidc_hostpath}:sub" = local.sa_sub,
          "${local.oidc_hostpath}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
  tags = var.tags
}

# Inline policy: grant this IRSA role read-only access to one secret
# and decryption permissions for its KMS key
resource "aws_iam_role_policy" "read_secret" {
  name = "allow-read-db-secret"
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ReadSecretValue",
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        Resource = var.secret_arn
      },
      {
        Sid      = "KmsDecrypt",
        Effect   = "Allow",
        Action   = ["kms:Decrypt"],
        Resource = var.kms_key_arn
      }
    ]
  })
}