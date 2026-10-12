variable "name_prefix" {
  description = "Naming prefix for database resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC hosting the database."
  type        = string
}

variable "database_subnet_ids" {
  description = "Isolated subnet IDs used by RDS."
  type        = list(string)

  validation {
    condition     = length(var.database_subnet_ids) >= 2
    error_message = "RDS requires database subnets across at least two Availability Zones."
  }
}

variable "db_identifier" {
  description = "RDS DB instance identifier."
  type        = string
}

variable "database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "traveljournal"
}

variable "master_username" {
  description = "RDS bootstrap administrator username."
  type        = string
  default     = "stjadmin"
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "17.11"
}

variable "instance_class" {
  description = "RDS DB instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "database_port" {
  description = "PostgreSQL listener port."
  type        = number
  default     = 5433
}

variable "allocated_storage" {
  description = "Initial GP3 storage allocation in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage allocation through RDS storage autoscaling."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ high availability."
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Automated backup retention period."
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds."
  type        = number
  default     = 60
}

variable "deletion_protection" {
  description = "Protect the RDS instance from accidental deletion."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot during deletion."
  type        = bool
  default     = false
}

variable "database_log_retention_days" {
  description = "Retention period for RDS CloudWatch logs."
  type        = number
  default     = 365

  validation {
    condition     = var.database_log_retention_days >= 365
    error_message = "Database log retention must be at least 365 days."
  }
}

variable "eks_cluster_security_group_id" {
  description = "EKS cluster security group used by cluster DNS/system workloads."
  type        = string
}