variable "aws_region" {
  description = "AWS region for the SecVault deployment."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name used for tagging and naming."
  type        = string
  default     = "dev"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Project identifier used in resource names and tags."
  type        = string
  default     = "secvault"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets hosting the ALB and NAT gateways."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "availability_zones" {
  description = "Availability zones used by the three-tier network."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway to reduce cost. Set false for one NAT Gateway per AZ."
  type        = bool
  default     = true
}

variable "db_username" {
  description = "RDS master username. The password is generated and managed by RDS/Secrets Manager."
  type        = string
  default     = "dbadmin"
}

variable "db_name" {
  description = "Initial RDS database name."
  type        = string
  default     = "secvault"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial RDS storage size in GiB."
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "RDS automated backup retention in days."
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Enable RDS Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent accidental RDS deletion. Enable for production."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final RDS snapshot on destroy. Keep false for production."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type for the application ASG."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum application ASG capacity."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum application ASG capacity."
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired application ASG capacity."
  type        = number
  default     = 1
}

variable "alb_certificate_arn" {
  description = "Optional ACM certificate ARN. When set, the ALB exposes HTTPS on port 443."
  type        = string
  default     = null
}

variable "app_repository" {
  description = "Git repository cloned by application instances during bootstrap."
  type        = string
  default     = "https://github.com/Ibad84671/secvault-aws-terraform.git"
}

variable "app_git_ref" {
  description = "Git branch, tag, or commit checked out by application instances."
  type        = string
  default     = "main"
}

variable "enable_guardduty" {
  description = "Enable GuardDuty in the deployment region."
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable Security Hub CSPM in the deployment region. This may incur additional AWS charges."
  type        = bool
  default     = false
}

variable "security_alert_email" {
  description = "Optional email endpoint for security EventBridge/SNS notifications."
  type        = string
  default     = null
}

variable "cloudtrail_retention_days" {
  description = "Retention period for CloudTrail objects in the audit bucket."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Additional tags merged with SecVault standard Project, Environment, and ManagedBy tags."
  type        = map(string)
  default     = {
    SecurityClassification = "security-infrastructure"
  }
}
