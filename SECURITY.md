# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Security Architecture & Best Practices

This project implements the following security baselines:

- **Network Isolation:** Compute (ASG) and Database (RDS) resources are deployed inside private subnets without direct public IP addresses.
- **Least Privilege Access:** Security Groups restrict incoming traffic explicitly (ALB $\rightarrow$ App $\rightarrow$ Database).
- **Secrets Management:** Sensitive variables are passed via variables (`*.tfvars`) which are explicitly excluded from Git tracking via `.gitignore`.
- **Infrastructure State Security:** Local state files containing sensitive resource metadata are excluded from version control.

## Reporting a Vulnerability

If you discover a potential security vulnerability within this repository or infrastructure code, please **do not create a public GitHub issue**.

Instead, please report it via one of the following methods:
1. Contact the maintainer directly via GitHub profile.
2. Email: `ibad84671@gmail.com`

Vulnerabilities will be addressed promptly.