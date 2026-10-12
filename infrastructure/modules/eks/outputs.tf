output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_version" {
  description = "Kubernetes version."
  value       = aws_eks_cluster.this.version
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group automatically created by EKS."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_role_arn" {
  description = "EKS Auto Mode cluster IAM role."
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "EKS Auto Mode node IAM role."
  value       = aws_iam_role.node.arn
}

output "control_plane_log_group" {
  description = "CloudWatch log group containing EKS control-plane logs."
  value       = aws_cloudwatch_log_group.control_plane.name
}

output "backend_node_role_arn" {
  description = "IAM role used by the secured backend Auto Mode NodeClass."
  value       = aws_iam_role.backend_node.arn
}

output "backend_node_role_name" {
  description = "IAM role name used by the secured backend Auto Mode NodeClass."
  value       = aws_iam_role.backend_node.name
}