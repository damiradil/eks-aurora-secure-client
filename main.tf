module "vpc" {
  source = "./modules/vpc"

  name          = "${var.project_name}-vpc"
  cluster_name  = "${var.project_name}-eks"
  cidr          = var.vpc_cidr
  az_count      = var.az_count
  private_cidrs = var.private_subnet_cidrs
  public_cidrs  = var.public_subnet_cidrs
  tags          = var.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  public_access   = var.eks_endpoint_public_access
  public_cidrs    = var.eks_public_access_cidrs
  tags            = var.tags
}

module "aurora" {
  source              = "./modules/aurora"
  name                = var.project_name
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  eks_node_sg_id      = module.eks.node_sg_id
  db_engine_version   = var.db_engine_version
  db_name             = var.db_name
  db_master_username  = var.db_master_username
  min_acu             = var.aurora_min_acu
  max_acu             = var.aurora_max_acu
  tags                = var.tags

  # unique name to avoid the scheduled-deletion collision
  secret_name         = "${var.project_name}/db/master-helium"
}

module "eks_addons" {
  source      = "./modules/eks-addons"
  namespace   = "kube-system"
  depends_on  = [module.eks]
}

module "iam_irsa_db_client" {
  source               = "./modules/iam-irsa"
  oidc_provider_arn    = module.eks.oidc_provider_arn
  namespace            = "db-client"          
  service_account_name = "db-client-sa"
  secret_arn           = module.aurora.secret_arn
  kms_key_arn          = module.aurora.kms_key_arn
  role_name            = "${var.project_name}-db-client-irsa"
  tags                 = var.tags
  depends_on           = [module.eks]
}

module "db_client" {
  source               = "./modules/db-client"
  namespace            = "db-client"
  service_account_name = "db-client-sa"
  irsa_role_arn        = module.iam_irsa_db_client.role_arn
  secret_arn           = module.aurora.secret_arn
  db_endpoint          = module.aurora.cluster_endpoint
  db_name              = var.db_name
  job_name             = "psql-now"
  depends_on           = [module.eks]
}
