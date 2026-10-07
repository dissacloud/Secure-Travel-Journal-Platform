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