output "db_instance_id" {
  description = "RDS PostgreSQL instance identifier."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS PostgreSQL instance ARN."
  value       = aws_db_instance.this.arn
}

output "database_endpoint" {
  description = "RDS PostgreSQL DNS endpoint."
  value       = aws_db_instance.this.address
}

output "database_port" {
  description = "RDS PostgreSQL listener port."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial PostgreSQL database."
  value       = aws_db_instance.this.db_name
}

output "database_security_group_id" {
  description = "Security group protecting PostgreSQL."
  value       = aws_security_group.database.id
}

output "application_db_client_security_group_id" {
  description = "Security group future application Pods must use to access PostgreSQL."
  value       = aws_security_group.application_db_client.id
}

output "master_secret_arn" {
  description = "Secrets Manager ARN for the RDS-managed master credential."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "storage_kms_key_arn" {
  description = "KMS key encrypting RDS storage."
  value       = aws_kms_key.database_storage.arn
}

output "master_secret_kms_key_arn" {
  description = "KMS key encrypting the RDS-managed master credential."
  value       = aws_kms_key.master_secret.arn
}

output "db_resource_id" {
  description = "Immutable RDS DB instance resource ID used for IAM database authentication."
  value       = aws_db_instance.this.resource_id
}