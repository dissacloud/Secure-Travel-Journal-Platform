variable "aws_region" {
  description = "AWS region hosting Terraform state."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project naming prefix."
  type        = string
  default     = "secure-travel-journal"
}