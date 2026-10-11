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

output "vpc_id" {
  description = "Dev platform VPC ID."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "Dev platform VPC CIDR."
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public load-balancer subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private EKS subnet IDs."
  value       = module.network.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Isolated database subnet IDs."
  value       = module.network.database_subnet_ids
}

output "nat_gateway_id" {
  description = "Regional NAT Gateway."
  value       = module.network.nat_gateway_id
}

output "vpc_flow_log_group" {
  description = "VPC Flow Log group."
  value       = module.network.flow_log_group_name
}

output "eks_cluster_name" {
  description = "Dev EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "Dev EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "eks_cluster_version" {
  description = "Dev Kubernetes version."
  value       = module.eks.cluster_version
}

output "eks_cluster_endpoint" {
  description = "Dev Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group."
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_role_arn" {
  description = "EKS control-plane IAM role."
  value       = module.eks.cluster_role_arn
}

output "eks_node_role_arn" {
  description = "EKS Auto Mode node role."
  value       = module.eks.node_role_arn
}

output "rds_instance_id" {
  description = "Dev PostgreSQL RDS instance."
  value       = module.database.db_instance_id
}

output "rds_endpoint" {
  description = "Dev PostgreSQL endpoint."
  value       = module.database.database_endpoint
}

output "rds_port" {
  description = "Dev PostgreSQL port."
  value       = module.database.database_port
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN for the RDS bootstrap credential."
  value       = module.database.master_secret_arn
}

output "rds_security_group_id" {
  description = "Security group protecting RDS."
  value       = module.database.database_security_group_id
}

output "application_db_client_security_group_id" {
  description = "Security group future Travel Journal Pods require for database connectivity."
  value       = module.database.application_db_client_security_group_id
}
