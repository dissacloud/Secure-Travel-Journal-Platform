output "aws_account_id" {
  description = "AWS account hosting the dev platform."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region hosting the dev platform."
  value       = var.aws_region
}

output "environment" {
  description = "Platform environment."
  value       = var.environment
}