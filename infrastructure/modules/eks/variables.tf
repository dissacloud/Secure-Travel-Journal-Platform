variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes control-plane version."
  type        = string
  default     = "1.36"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS control plane and Auto Mode nodes."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "EKS requires private subnets across at least two Availability Zones."
  }
}

variable "service_ipv4_cidr" {
  description = "IPv4 CIDR allocated to Kubernetes services."
  type        = string
  default     = "172.20.0.0/16"
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API has a restricted public endpoint."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDRs permitted to reach the public Kubernetes API endpoint."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.public_access_cidrs :
      cidr != "0.0.0.0/0" &&
      cidr != "::/0" &&
      can(cidrhost(cidr, 0))
    ])

    error_message = "Public EKS API access must never permit 0.0.0.0/0 or ::/0."
  }
}

variable "admin_principal_arn" {
  description = "IAM role or user granted initial EKS cluster administration."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:aws:iam::[0-9]{12}:(role|user)/.+$",
        var.admin_principal_arn
      )
    )

    error_message = "Use an IAM role/user ARN, not an STS assumed-role session ARN."
  }
}

variable "control_plane_log_retention_days" {
  description = "CloudWatch retention for EKS control-plane logs."
  type        = number
  default     = 365

  validation {
    condition = contains(
      [365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653],
      var.control_plane_log_retention_days
    )

    error_message = "Choose a supported CloudWatch retention period of at least 365 days."
  }
}

variable "deletion_protection" {
  description = "Protect the EKS cluster from accidental deletion."
  type        = bool
  default     = true
}