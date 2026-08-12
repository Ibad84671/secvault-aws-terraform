variable "project_name" {
  default = "secvault"
}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "db_sg_id" {
  type = string
}

variable "db_name" {
  default = "secvault"
}

variable "db_user" {
  default = "dbadmin"
}

variable "db_password" {
  default = "SecVaultPass2026!"
}