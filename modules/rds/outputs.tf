output "db_host" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.mysql.address
}

output "db_security_group_id" {
  description = "RDS security group ID."
  value       = var.db_security_group_id
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN managed by RDS for the master credentials."
  value       = aws_db_instance.mysql.master_user_secret[0].secret_arn
}

output "db_kms_key_arn" {
  description = "KMS key ARN used for RDS and the RDS-managed master secret."
  value       = aws_kms_key.db.arn
}
