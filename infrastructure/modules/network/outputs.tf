output "vpc_id" {
  description = "Platform VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "Platform VPC CIDR."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public load-balancer subnet IDs."

  value = [
    for az in var.availability_zones :
    aws_subnet.public[az].id
  ]
}

output "private_subnet_ids" {
  description = "Private EKS workload subnet IDs."

  value = [
    for az in var.availability_zones :
    aws_subnet.private[az].id
  ]
}

output "database_subnet_ids" {
  description = "Isolated database subnet IDs."

  value = [
    for az in var.availability_zones :
    aws_subnet.database[az].id
  ]
}

output "availability_zones" {
  description = "Availability Zones used by the platform."
  value       = var.availability_zones
}

output "nat_gateway_id" {
  description = "Regional NAT Gateway ID."
  value       = aws_nat_gateway.this.id
}

output "flow_log_group_name" {
  description = "CloudWatch group containing VPC Flow Logs."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

