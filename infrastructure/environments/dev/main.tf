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