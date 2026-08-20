variable "project_name" {
  description = "Project identifier."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for flow logging."
  type        = string
}

variable "enable_guardduty" {
  description = "Enable GuardDuty."
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable Security Hub CSPM."
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Optional email subscription endpoint for security alerts."
  type        = string
  default     = null
}

variable "cloudtrail_retention_days" {
  description = "CloudTrail S3 object retention in days."
  type        = number
  default     = 90
}

variable "force_destroy_log_bucket" {
  description = "Allow Terraform destroy to delete non-empty audit buckets. Keep false for production."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}
