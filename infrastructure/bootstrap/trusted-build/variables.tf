variable "aws_region" {
  description = "AWS region used by the trusted build platform."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Resource naming prefix."
  type        = string
  default     = "secure-travel-journal"
}

variable "github_owner" {
  description = "GitHub repository owner."
  type        = string
  default     = "dissacloud"
}

variable "github_owner_id" {
  description = "Immutable numeric GitHub owner ID."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name."
  type        = string
  default     = "Secure-Travel-Journal-Platform"
}

variable "github_repository_id" {
  description = "Immutable numeric GitHub repository ID."
  type        = string
}