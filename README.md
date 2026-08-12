# Production-Grade 3-Tier AWS Architecture via Terraform
![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-623CE4?style=flat&logo=terraform)
![AWS](https://img.shields.io/badge/AWS-3--Tier%20Architecture-232F3E?style=flat&logo=amazon-aws)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Security](https://img.shields.io/badge/DevSecOps-Compliant-brightgreen)

> Automated, highly available, and secure 3-Tier AWS infrastructure deployment using modular Terraform and Python.

---

## 🏛️ Architecture Overview

This repository provisions an enterprise-standard 3-tier cloud architecture on AWS using **Terraform (Infrastructure as Code)**. The application workload is isolated in private subnets, fronted by an Application Load Balancer (ALB), and backed by a relational database tier (Amazon RDS MySQL).

```mermaid
flowchart TD
    User([Internet User]) -->|HTTP :80| ALB[Application Load Balancer\nPublic Subnets]
    
    subgraph VPC [Custom AWS VPC]
        subgraph PublicSubnets [Public Subnets - Multi-AZ]
            ALB
            IGW[Internet Gateway]
            NAT[NAT Gateway]
        end
        
        subgraph PrivateAppSubnets [Private App Subnets - Multi-AZ]
            ASG[Auto Scaling Group\nEC2 App Instances - Python Flask]
        end
        
        subgraph PrivateDBSubnets [Private DB Subnets - Multi-AZ]
            RDS[(Amazon RDS MySQL\nPrimary DB)]
        end
    end
    
    ALB -->|Forward Traffic :5000| ASG
    ASG -->|Outbound DB Traffic :3306| RDS
    ASG -->|Outbound Internet Updates| NAT --> IGW
