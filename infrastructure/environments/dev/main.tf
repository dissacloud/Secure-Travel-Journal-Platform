data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  common_tags = {
    Project     = "SecureTravelJournal"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "Secure-Travel-Journal-Platform"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix = "${var.project_name}-${var.environment}"

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnet_cidrs = var.public_subnet_cidrs

  private_subnet_cidrs = var.private_subnet_cidrs

  database_subnet_cidrs = var.database_subnet_cidrs

  flow_log_retention_days = var.flow_log_retention_days
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "${var.project_name}-${var.environment}"

  cluster_version = var.eks_cluster_version

  private_subnet_ids = module.network.private_subnet_ids

  service_ipv4_cidr = var.eks_service_ipv4_cidr

  endpoint_public_access = var.eks_endpoint_public_access

  public_access_cidrs = var.eks_public_access_cidrs

  admin_principal_arn = var.eks_admin_principal_arn

  deletion_protection = var.eks_deletion_protection
}

module "database" {
  source = "../../modules/database"

  name_prefix = "${var.project_name}-${var.environment}"

  vpc_id = module.network.vpc_id

  database_subnet_ids = module.network.database_subnet_ids

  db_identifier = "${var.project_name}-${var.environment}-postgres"

  database_name = "traveljournal"

  master_username = "stjadmin"

  engine_version = var.database_engine_version

  instance_class = var.database_instance_class

  database_port = var.database_port

  multi_az = var.database_multi_az

  deletion_protection = var.database_deletion_protection

  eks_cluster_security_group_id = module.eks.cluster_security_group_id
}

module "security" {
  source = "../../modules/security"

  cluster_name = module.eks.cluster_name

  kubernetes_namespace = "travel-journal"

  backend_service_account = "backend"

  database_bootstrap_service_account = "database-bootstrap"

  database_resource_id = module.database.db_resource_id

  application_database_user = "traveljournal_app"

  master_secret_arn = module.database.master_secret_arn

  master_secret_kms_key_arn = module.database.master_secret_kms_key_arn
}
