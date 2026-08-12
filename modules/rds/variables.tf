variable "project_name" { type = string }
variable "db_subnet_ids" { type = list(string) }
variable "db_security_group_id" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "db_instance_class" { type = string }
variable "allocated_storage" { type = number }
variable "backup_retention_period" {
  type    = number
  default = 7
}
variable "multi_az" {
  type    = bool
  default = false
}
variable "kms_key_id" {
  type    = string
  default = null
}
variable "tags" { type = map(string) }