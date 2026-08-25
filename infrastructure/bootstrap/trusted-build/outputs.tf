output "aws_account_id" {
  description = "AWS account hosting the trusted build resources."
  value       = data.aws_caller_identity.current.account_id
}

output "trusted_build_role_arn" {
  description = "IAM role assumed by GitHub Actions using OIDC."
  value       = aws_iam_role.github_trusted_build.arn
}

output "github_oidc_subject" {
  description = "Exact GitHub OIDC subject trusted by AWS."
  value       = local.github_oidc_subject
}

output "ecr_repository_urls" {
  description = "Application ECR repositories."

  value = {
    for component, repository in aws_ecr_repository.application :
    component => repository.repository_url
  }
}

output "artifact_verifier_role_arn" {
  description = "Read-only IAM role used to verify trusted ECR artifacts."
  value       = aws_iam_role.github_artifact_verifier.arn
}