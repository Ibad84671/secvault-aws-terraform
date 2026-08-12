output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_host
}

output "rds_secret_arn" {
  description = "RDS secret ARN (if using Secrets Manager)"
  value       = module.rds.secret_arn
}