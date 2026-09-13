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