# Security Policy

## Supported versions

The `main` branch is the actively maintained version of SecVault. Feature branches are considered development work and may contain incomplete security controls.

## Reporting a vulnerability

Please do not disclose exploitable security issues in a public GitHub issue.

Use GitHub's private vulnerability reporting/security advisory workflow for this repository when available. Include:

- affected file/resource
- impact and attack path
- reproduction steps that do not expose real credentials
- suggested remediation, if known

## Secret handling

Never commit:

- AWS access keys
- secret keys
- database passwords
- API tokens
- private keys
- Terraform state files
- production `.tfvars` files

SecVault intentionally uses RDS-managed Secrets Manager credentials for the database password. If a secret is accidentally committed, revoke/rotate it immediately; deleting the Git commit alone is not sufficient.

## Security philosophy

SecVault follows defense-in-depth and least-privilege principles. It is not represented as a guarantee of complete security, compliance, or immunity from compromise.
