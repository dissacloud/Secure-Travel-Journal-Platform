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