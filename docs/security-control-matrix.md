# Security Control Matrix

| Threat / objective | Control | AWS service / implementation | Detection / evidence | Status |
|---|---|---|---|---|
| Credential theft | No static AWS credentials on EC2 | IAM role + SSM | CloudTrail | Implemented |
| Privilege escalation | Narrow application secret permissions | IAM policy | CloudTrail IAM events | Implemented |
| Metadata credential theft | IMDSv2 required | EC2 Launch Template | CloudTrail / host telemetry | Implemented |
| Public application exposure | Public entry point only at ALB | ALB + SG | ALB access logs | Implemented |
| Public DB exposure | Private subnets + SG chaining | VPC + RDS + SG | VPC Flow Logs | Implemented |
| Database compromise | Encryption at rest | RDS + KMS | CloudTrail | Implemented |
| Secret disclosure | RDS-managed Secrets Manager secret | RDS + Secrets Manager | CloudTrail | Implemented |
| Audit loss | Multi-region trail + log validation | CloudTrail | S3 audit bucket | Implemented |
| Audit storage exposure | Block public access + TLS-only bucket policy | S3 | CloudTrail/S3 audit trail | Implemented |
| Audit retention | Versioning + lifecycle | S3 | S3 object history | Implemented |
| Network investigation | Flow logs | VPC Flow Logs + CloudWatch | CloudWatch Logs | Implemented |
| Threat detection | Findings for supported AWS threats | GuardDuty | GuardDuty findings | Implemented |
| Security posture aggregation | Standards/findings | Security Hub | Security Hub findings | Optional |
| IAM security changes | Targeted event pattern | EventBridge | SNS | Implemented |
| Finding notification | Encrypted topic | SNS | Email subscription | Implemented |
| IaC regression | Static security checks | Checkov + Trivy | GitHub Code Scanning | Implemented |
| Infrastructure reproducibility | Declarative infrastructure | Terraform modules | CI validation | Implemented |

## Control philosophy

A control is listed only when it exists in Terraform or in the application implementation. Optional services are explicitly marked optional instead of being presented as deployed by default.
