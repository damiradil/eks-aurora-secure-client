output "cluster_endpoint" { value = module.aurora.cluster_endpoint }
output "secret_arn"       { value = aws_secretsmanager_secret.db_master.arn }
output "security_group_id"{ value = aws_security_group.aurora.id }

output "kms_key_arn" { value = aws_kms_key.db.arn }
