output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnets" { value = module.vpc.private_subnets }
output "public_subnets" { value = module.vpc.public_subnets }

output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "eks_oidc_provider_arn" { value = module.eks.oidc_provider_arn }
output "eks_node_sg_id" { value = module.eks.node_sg_id }

output "aurora_cluster_endpoint" { value = module.aurora.cluster_endpoint }
output "db_secret_arn"           { value = module.aurora.secret_arn }

output "aurora_kms_key_arn" { value = module.aurora.kms_key_arn }

output "db_client_irsa_role_arn" {
  value = module.iam_irsa_db_client.role_arn
}

output "db_client_namespace" { value = module.db_client.namespace }
output "db_client_job_name"  { value = module.db_client.job_name }
