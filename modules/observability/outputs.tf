output "cloudtrail_bucket_name" {
  description = "S3 bucket storing CloudTrail audit logs."
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN."
  value       = aws_cloudtrail.this.arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID when enabled."
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}

output "security_alert_topic_arn" {
  description = "SNS topic receiving security events."
  value       = aws_sns_topic.security.arn
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch log group receiving VPC flow logs."
  value       = aws_cloudwatch_log_group.vpc_flow.name
}
