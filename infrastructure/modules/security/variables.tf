variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Namespace hosting the Travel Journal workloads."
  type        = string
  default     = "travel-journal"
}

variable "backend_service_account" {
  description = "Kubernetes service account used by the backend."
  type        = string
  default     = "backend"
}

variable "database_bootstrap_service_account" {
  description = "Service account permitted to bootstrap the application database."
  type        = string
  default     = "database-bootstrap"
}

variable "database_resource_id" {
  description = "RDS immutable DB resource ID."
  type        = string
}

variable "application_database_user" {
  description = "Least-privilege PostgreSQL identity used by the application."
  type        = string
  default     = "traveljournal_app"
}

variable "master_secret_arn" {
  description = "RDS-managed master credential secret ARN."
  type        = string
}

variable "master_secret_kms_key_arn" {
  description = "KMS key encrypting the RDS master secret."
  type        = string
}