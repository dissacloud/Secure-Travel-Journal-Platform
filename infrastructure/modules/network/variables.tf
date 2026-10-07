variable "name_prefix" {
  description = "Naming prefix for networking resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR assigned to the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by the platform."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs assigned to public load-balancer subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs assigned to private EKS workload subnets."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDRs assigned to isolated database subnets."
  type        = list(string)
}

variable "flow_log_retention_days" {
  description = "Retention period in days for VPC Flow Logs"
  type        = number
  default     = 365

  validation {
    condition     = var.flow_log_retention_days >= 365
    error_message = "VPC Flow Log retention must be at least 365 days."
  }
}