output "cluster_name"       { value = module.eks.cluster_name }
output "cluster_endpoint"   { value = module.eks.cluster_endpoint }
output "oidc_provider_arn"  { value = module.eks.oidc_provider_arn }
output "node_sg_id"         { value = module.eks.node_security_group_id }
