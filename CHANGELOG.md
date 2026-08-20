# Changelog

All notable changes to SecVault are documented here.

## Unreleased

### Security

- Hardened the network into public ALB, private application, and private database tiers.
- Removed plaintext database password handling from Terraform variables and EC2 user data.
- Enabled RDS-managed Secrets Manager credentials with customer-managed KMS encryption.
- Added IMDSv2 enforcement and encrypted EBS volumes.
- Added multi-region CloudTrail with log validation and protected audit storage.
- Added VPC Flow Logs, GuardDuty, targeted IAM-change EventBridge rules, and encrypted SNS alerting.

### Terraform

- Added a dedicated observability module.
- Improved module inputs, outputs, tagging, validation, and cost/resilience controls.
- Added optional HTTPS with HTTP-to-HTTPS redirect.
- Added ALB access logging and RDS/EC2 observability.

### CI/CD

- Added Terraform format/validate checks.
- Added Checkov and Trivy IaC scanning with SARIF upload.
- Added an optional OIDC-based Terraform plan path.

### Documentation

- Rebuilt the README around architecture, threats, controls, deployment, validation, costs, and limitations.
- Added threat model, security control matrix, architecture notes, SECURITY.md, and CONTRIBUTING.md.
