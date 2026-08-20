variable "project_name" {
  description = "Project identifier used in resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "Private application subnet CIDRs."
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "Private database subnet CIDRs."
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones aligned by subnet index."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use one shared NAT Gateway instead of one per AZ."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}
