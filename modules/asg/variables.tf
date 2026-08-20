variable "project_name" {
  description = "Project identifier."
  type        = string
}

variable "app_subnet_ids" {
  description = "Private application subnet IDs."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Application tier security group ID."
  type        = string
}

variable "alb_target_group_arn" {
  description = "ALB target group ARN."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "min_size" {
  description = "Minimum ASG capacity."
  type        = number
}

variable "max_size" {
  description = "Maximum ASG capacity."
  type        = number
}

variable "desired_capacity" {
  description = "Desired ASG capacity."
  type        = number
}

variable "db_secret_arn" {
  description = "RDS-managed Secrets Manager ARN containing database credentials."
  type        = string
}

variable "db_secret_kms_key_arn" {
  description = "KMS key used to encrypt the RDS-managed database secret."
  type        = string
}

variable "db_name" {
  description = "Database name exposed to the application."
  type        = string
}

variable "app_repository" {
  description = "Git repository containing the application."
  type        = string
}

variable "app_git_ref" {
  description = "Git ref checked out during instance bootstrap."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}
