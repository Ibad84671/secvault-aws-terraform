variable "project_name" {
  type    = string
  default = "secvault"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "db_name" {
  type    = string
  default = "secvault"
}

variable "db_user" {
  type    = string
  default = "dbadmin"
}

variable "db_password" {
  type    = string
  default = "SecVaultPass2026!"
}