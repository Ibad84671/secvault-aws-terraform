variable "project_name" {
  description = "Project identifier."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing ALB."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ALB security group ID."
  type        = string
}

variable "access_log_bucket" {
  description = "S3 bucket receiving ALB access logs."
  type        = string
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN used to enable HTTPS and redirect HTTP to HTTPS."
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from accidental deletion."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}
