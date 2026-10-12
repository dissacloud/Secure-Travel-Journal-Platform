output "backend_pod_role_arn" {
  description = "IAM role used by the Travel Journal backend through EKS Pod Identity."
  value       = aws_iam_role.backend.arn
}

output "database_bootstrap_pod_role_arn" {
  description = "IAM role used by the one-time database bootstrap workload."
  value       = aws_iam_role.database_bootstrap.arn
}