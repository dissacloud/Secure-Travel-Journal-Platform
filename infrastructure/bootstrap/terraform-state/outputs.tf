output "state_bucket_name" {
  description = "S3 bucket containing Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_kms_key_arn" {
  description = "KMS key used to encrypt Terraform state."
  value       = aws_kms_key.terraform_state.arn
}

output "state_kms_alias" {
  description = "KMS alias used for Terraform state encryption."
  value       = aws_kms_alias.terraform_state.name
}

output "backend_region" {
  description = "AWS region containing Terraform state."
  value       = var.aws_region
}