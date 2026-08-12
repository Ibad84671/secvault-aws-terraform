# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | ✅ |

## Reporting a Vulnerability

**Security is a top priority.** If you discover a vulnerability:

1. **DO NOT** create a public GitHub issue
2. Email: [ibad84671@gmail.com](mailto:ibad84671@gmail.com)
3. Include: Description, Steps to Reproduce, Potential Impact
4. Expect response within 48 hours

## Security Controls in Place

- ✅ **Secrets Manager** – DB credentials never in code or user_data
- ✅ **SSM Session Manager** – No SSH, no public port 22
- ✅ **Security Group Chaining** – ALB SG → App SG → DB SG
- ✅ **Private Subnets** – App & DB tiers have no public IPs
- ✅ **Encryption at Rest** – RDS encrypted with KMS
- ✅ **IMDSv2** – Enforced on EC2 instances
- ✅ **Terraform Security Scanning** – Checkov + tfsec in CI pipeline

## Security Architecture

## Responsible Disclosure

We follow responsible disclosure practices. Vulnerabilities are fixed within 14 days of confirmation.