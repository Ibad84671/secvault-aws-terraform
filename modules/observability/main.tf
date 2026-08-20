data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "cloudtrail_bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals { type = "Service" identifiers = ["cloudtrail.amazonaws.com"] }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = [aws_cloudtrail.this.arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals { type = "Service" identifiers = ["cloudtrail.amazonaws.com"] }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = ["bucket-owner-full-control"]
    }
    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = [aws_cloudtrail.this.arn]
    }
  }

  statement {
    sid    = "ALBAccessLogWrite"
    effect = "Allow"
    principals { type = "Service" identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"] }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/${var.project_name}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = ["arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/*"]
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals { type = "*" identifiers = ["*"] }
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.cloudtrail.arn, "${aws_s3_bucket.cloudtrail.arn}/*"]
    condition {
      test = "Bool"
      variable = "aws:SecureTransport"
      values = ["false"]
    }
  }
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket_prefix = "${var.project_name}-${data.aws_caller_identity.current.account_id}-audit-"
  force_destroy = var.force_destroy_log_bucket
  tags = merge(var.tags, { Name = "${var.project_name}-cloudtrail" })
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    id = "audit-log-retention"
    status = "Enabled"
    filter {}
    expiration { days = var.cloudtrail_retention_days }
    noncurrent_version_expiration { noncurrent_days = 30 }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json
}

resource "aws_cloudtrail" "this" {
  name = "${var.project_name}-trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail = true
  enable_log_file_validation = true
  enable_logging = true
  depends_on = [aws_s3_bucket_policy.cloudtrail]
  tags = merge(var.tags, { Name = "${var.project_name}-trail" })
}

resource "aws_cloudwatch_log_group" "vpc_flow" {
  name = "/aws/vpc/${var.project_name}/flow-logs"
  retention_in_days = 30
  tags = merge(var.tags, { Name = "${var.project_name}-vpc-flow-logs" })
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    effect = "Allow"
    principals { type = "Service" identifiers = ["vpc-flow-logs.amazonaws.com"] }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role.json
  tags = var.tags
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogStream", "logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.vpc_flow.arn}:*"]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-vpc-flow-logs"
  role = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "vpc" {
  vpc_id = var.vpc_id
  traffic_type = "ALL"
  iam_role_arn = aws_iam_role.flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  log_destination = aws_cloudwatch_log_group.vpc_flow.arn
  tags = merge(var.tags, { Name = "${var.project_name}-vpc-flow-log" })
}

resource "aws_guardduty_detector" "this" {
  count = var.enable_guardduty ? 1 : 0
  enable = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags = merge(var.tags, { Name = "${var.project_name}-guardduty" })
}

resource "aws_guardduty_detector_feature" "s3" {
  count = var.enable_guardduty ? 1 : 0
  detector_id = aws_guardduty_detector.this[0].id
  name = "S3_DATA_EVENTS"
  status = "ENABLED"
}

resource "aws_securityhub_account" "this" {
  count = var.enable_security_hub ? 1 : 0
  enable_default_standards = true
  auto_enable_controls = true
}

resource "aws_sns_topic" "security" {
  name = "${var.project_name}-security-alerts"
  kms_master_key_id = "alias/aws/sns"
  tags = merge(var.tags, { Name = "${var.project_name}-security-alerts" })
}

data "aws_iam_policy_document" "security_topic" {
  statement {
    sid = "AllowEventBridgePublish"
    effect = "Allow"
    principals { type = "Service" identifiers = ["events.amazonaws.com"] }
    actions = ["sns:Publish"]
    resources = [aws_sns_topic.security.arn]
    condition {
      test = "ArnEquals"
      variable = "aws:SourceArn"
      values = compact([
        var.enable_guardduty ? aws_cloudwatch_event_rule.guardduty[0].arn : null,
        aws_cloudwatch_event_rule.iam_changes.arn,
        var.enable_security_hub ? aws_cloudwatch_event_rule.securityhub[0].arn : null,
      ])
    }
  }
}

resource "aws_sns_topic_policy" "security" {
  arn = aws_sns_topic.security.arn
  policy = data.aws_iam_policy_document.security_topic.json
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email == null ? 0 : 1
  topic_arn = aws_sns_topic.security.arn
  protocol = "email"
  endpoint = var.alert_email
}

resource "aws_cloudwatch_event_rule" "guardduty" {
  count = var.enable_guardduty ? 1 : 0
  name = "${var.project_name}-guardduty-findings"
  description = "Route GuardDuty findings to the SecVault security notification topic."
  event_pattern = jsonencode({
    source = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "guardduty" {
  count = var.enable_guardduty ? 1 : 0
  rule = aws_cloudwatch_event_rule.guardduty[0].name
  target_id = "security-sns"
  arn = aws_sns_topic.security.arn
}

resource "aws_cloudwatch_event_rule" "securityhub" {
  count = var.enable_security_hub ? 1 : 0
  name = "${var.project_name}-securityhub-findings"
  description = "Route Security Hub findings to the SecVault security notification topic."
  event_pattern = jsonencode({
    source = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
  })
}

resource "aws_cloudwatch_event_target" "securityhub" {
  count = var.enable_security_hub ? 1 : 0
  rule = aws_cloudwatch_event_rule.securityhub[0].name
  target_id = "security-sns"
  arn = aws_sns_topic.security.arn
}

resource "aws_cloudwatch_event_rule" "iam_changes" {
  name = "${var.project_name}-iam-security-changes"
  description = "Capture high-value IAM changes that can affect account security posture."
  event_pattern = jsonencode({
    source = ["aws.iam"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName = [
        "CreateUser", "DeleteUser", "CreateRole", "DeleteRole",
        "AttachUserPolicy", "DetachUserPolicy", "AttachRolePolicy", "DetachRolePolicy",
        "PutUserPolicy", "DeleteUserPolicy", "PutRolePolicy", "DeleteRolePolicy",
        "UpdateAssumeRolePolicy", "PassRole",
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_changes" {
  rule = aws_cloudwatch_event_rule.iam_changes.name
  target_id = "security-sns"
  arn = aws_sns_topic.security.arn
}
