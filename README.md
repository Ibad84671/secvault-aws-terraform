# 🛡️ SecVault - Enterprise AWS 3-Tier Architecture via Terraform

[![Terraform CI/Validation](https://github.com/Ibad84671/secvault-aws-terraform/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/Ibad84671/secvault-aws-terraform/actions/workflows/terraform-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![AWS](https://img.shields.io/badge/Cloud-AWS-orange?logo=amazon-aws)](https://aws.amazon.com/)

Production-grade, highly available, and secure 3-Tier cloud infrastructure deployed on AWS using modular Terraform (Infrastructure as Code) and automated through GitHub Actions CI/CD.

---

## 🏛️ Architecture Overview

The workload is isolated across multi-AZ private subnets, fronted by an Internet-facing Application Load Balancer (ALB), backed by an internal Auto Scaling Group (ASG) running Python Flask instances, and secured with a private MySQL RDS instance. Internet connectivity for private app instances is safely routed via a managed NAT Gateway.

```mermaid
flowchart TD
    User([Internet User]) -->|HTTP :80| ALB[Application Load Balancer\nPublic Subnets]

    subgraph VPC [Custom AWS VPC - Multi-AZ]
        subgraph PublicSubnets [Public Subnets]
            ALB
            IGW[Internet Gateway]
            NAT[NAT Gateway]
        end

        subgraph PrivateAppSubnets [Private App Subnets]
            ASG[Auto Scaling Group\nEC2 Python Flask Instances]
        end

        subgraph PrivateDBSubnets [Private DB Subnets]
            RDS[(Amazon RDS MySQL\nPrimary DB)]
        end
    end

    ALB -->|Forward Traffic :5000| ASG
    ASG -->|Outbound DB Traffic :3306| RDS
    ASG -->|Outbound Updates via NAT| NAT --> IGW
```

---

## 📂 Repository Structure

The project follows a decoupled, reusable Terraform module structure:

```
secvault-aws-terraform/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml   # Automated format & validation pipeline
├── app/
│   └── app.py                 # Python Flask SOC Dashboard application
├── modules/
│   ├── alb/                   # Application Load Balancer & Target Groups
│   ├── asg/                   # Launch Template, User-Data, and Auto Scaling
│   ├── rds/                   # Multi-AZ RDS MySQL Database tier
│   ├── security/              # Security Groups & least-privilege chaining
│   └── vpc/                   # Custom VPC, Subnets, Internet & NAT Gateways
├── main.tf                    # Root module composition
├── variables.tf               # Root input variables (securely parameterized)
├── outputs.tf                 # ALB DNS name & infrastructure outputs
└── provider.tf                # AWS provider configuration & version locking
```

---

## 🔒 Security & Best Practices Implemented

- **Network Isolation:** Zero public exposure for App and Database tiers; hosted entirely inside private subnets.
- **Security Group Chaining:** Strict ingress rules (ALB accepts HTTP from internet → App accepts port 5000 strictly from ALB → RDS accepts port 3306 strictly from App instances).
- **Zero Secrets in Code:** Sensitive variables (`db_password`) are parameterized without hardcoded defaults; `.gitignore` properly tracks `.terraform.lock.hcl` while keeping local state and sensitive `tfvars` secure.
- **Automated Governance:** GitHub Actions pipeline automatically validates and lints all infrastructure code on every pull request and push.

---

## 🚀 Step-by-Step Deployment Guide

### 📋 Prerequisites

- AWS CLI configured (`aws configure`) with appropriate permissions.
- Terraform CLI (v1.0+) installed.
- Git installed.

### 📥 1. Clone the Repository

```bash
git clone https://github.com/Ibad84671/secvault-aws-terraform.git
cd secvault-aws-terraform
```

### ⚙️ 2. Configure Environment Variables

Create a `terraform.tfvars` file in the root directory to supply your database secrets safely:

```hcl
db_username = "admin"
db_password = "YourSecurePassword123!"
```

### 🏗️ 3. Initialize & Deploy

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

(Type `yes` when prompted)

### 🌐 4. Access the Application

Once deployment completes, copy the output `alb_dns_name` and open it in your browser:

```
http://<alb_dns_name>
```

### 🧹 5. Clean Up (Destroy Infrastructure)

To avoid ongoing AWS charges:

```bash
terraform destroy
```

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.