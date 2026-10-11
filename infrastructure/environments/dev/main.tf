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