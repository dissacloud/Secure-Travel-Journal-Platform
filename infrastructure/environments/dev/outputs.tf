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