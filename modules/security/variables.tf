variable "project_name" {
  description = "Project identifier."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID containing the security groups."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR used for tightly scoped DNS egress."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}
