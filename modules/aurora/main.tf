# KMS key + alias for DB encryption
resource "aws_kms_key" "db" {
  description             = "DB encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "db_alias" {
  name          = "alias/${var.name}-db"
  target_key_id = aws_kms_key.db.key_id
}

# Random master password stored in Secrets Manager
resource "random_password" "master" {
  length           = 20
  special          = true
  # exclude '/', '@', '"', and space
  override_special = "!#$%&*+-.:;<=>?^_{|}~"
}


# Add random suffix to avoid collision with "scheduled for deletion" secrets
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "db_master" {
  name        = "${var.secret_name}-${random_id.suffix.hex}"
  description = "Aurora master credentials"
  kms_key_id  = aws_kms_key.db.arn
  tags        = var.tags
}

# Store generated username/password as JSON in the secret
resource "aws_secretsmanager_secret_version" "db_master_v1" {
  secret_id     = aws_secretsmanager_secret.db_master.id
  secret_string = jsonencode({
    username = var.db_master_username
    password = random_password.master.result
  })
}

# Security group for Aurora
resource "aws_security_group" "aurora" {
  name        = "${var.name}-aurora-sg"
  description = "Aurora security group"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

# Allow EKS nodes to connect to Aurora on PostgreSQL port 5432
resource "aws_security_group_rule" "ingress_from_nodes" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aurora.id
  source_security_group_id = var.eks_node_sg_id
  description              = "Allow EKS nodes to connect to Aurora"
}

# Allow Aurora instances to make outbound connections
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.aurora.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Aurora PostgreSQL Serverless v2 cluster (single writer, low cost)
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0"

  name           = "${var.name}-aurora"
  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = var.db_engine_version
  database_name  = var.db_name
  auto_minor_version_upgrade = true
  
  # Use generated credentials
  master_username             = jsondecode(aws_secretsmanager_secret_version.db_master_v1.secret_string)["username"]
  manage_master_user_password = false
  master_password             = random_password.master.result


  # Serverless v2 scaling configuration
  serverlessv2_scaling_configuration = {
    min_capacity = var.min_acu
    max_capacity = var.max_acu
  }

  # Only one writer instance (to keep cost low for this assesment)
  instances = {
    writer = { instance_class = "db.serverless" }
  }

  vpc_id                 = var.vpc_id
  subnets                = var.subnet_ids
  create_db_subnet_group = true
  db_subnet_group_name   = "${var.name}-aurora"
  vpc_security_group_ids = [aws_security_group.aurora.id]   

  storage_encrypted   = true
  kms_key_id          = aws_kms_key.db.arn
  apply_immediately   = true
  skip_final_snapshot = true

  tags = var.tags
}

