output "alb_dns_name" {
  description = "Public DNS name of the application load balancer."
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint hostname."
  value       = module.rds.db_host
}

output "rds_master_user_secret_arn" {
  description = "Secrets Manager ARN created and managed by RDS for the master credentials."
  value       = module.rds.master_user_secret_arn
}

output "vpc_id" {
  description = "SecVault VPC ID."
  value       = module.vpc.vpc_id
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket storing CloudTrail audit logs."
  value       = module.observability.cloudtrail_bucket_name
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN."
  value       = module.observability.cloudtrail_arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID when GuardDuty is enabled."
  value       = module.observability.guardduty_detector_id
}

output "security_alert_topic_arn" {
  description = "SNS topic receiving security EventBridge alerts."
  value       = module.observability.security_alert_topic_arn
}
