variable "aws_region" {
  description = "AWS region for the application platform."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project naming prefix."
  type        = string
  default     = "secure-travel-journal"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR for the dev platform VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by dev."
  type        = list(string)

  default = [
    "eu-west-2a",
    "eu-west-2b"
  ]
}

variable "public_subnet_cidrs" {
  description = "Public load-balancer subnet CIDRs."
  type        = list(string)

  default = [
    "10.40.0.0/24",
    "10.40.1.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "Private EKS workload subnet CIDRs."
  type        = list(string)

  default = [
    "10.40.16.0/20",
    "10.40.32.0/20"
  ]
}

variable "database_subnet_cidrs" {
  description = "Isolated database subnet CIDRs."
  type        = list(string)

  default = [
    "10.40.2.0/24",
    "10.40.3.0/24"
  ]
}

variable "flow_log_retention_days" {
  description = "VPC Flow Log retention period."
  type        = number
  default     = 365
}

variable "eks_cluster_version" {
  description = "Amazon EKS Kubernetes version."
  type        = string
  default     = "1.36"
}

variable "eks_service_ipv4_cidr" {
  description = "Kubernetes service network CIDR."
  type        = string
  default     = "172.20.0.0/16"
}

variable "eks_endpoint_public_access" {
  description = "Enable restricted public access to the Kubernetes API."
  type        = bool
  default     = false
}

variable "eks_public_access_cidrs" {
  description = "CIDRs allowed to access the EKS public API."
  type        = list(string)
  default     = []
}

variable "eks_admin_principal_arn" {
  description = "IAM principal granted EKS cluster administration."
  type        = string
}

variable "eks_deletion_protection" {
  description = "Enable EKS deletion protection."
  type        = bool
  default     = true
}

variable "database_engine_version" {
  description = "RDS PostgreSQL version."
  type        = string
  default     = "17.11"
}

variable "database_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "database_port" {
  description = "PostgreSQL listener port."
  type        = number
  default     = 5433
}

variable "database_multi_az" {
  description = "Enable RDS Multi-AZ deployment."
  type        = bool
  default     = true
}

variable "database_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
  default     = true
}