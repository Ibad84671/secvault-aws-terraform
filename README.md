# 🛡️ SecVault - Enterprise AWS 3-Tier Architecture via Terraform

Automated, highly available, and secure 3-Tier AWS infrastructure deployment using modular Terraform and Python.

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

Step-by-Step Deployment Guide
Follow these steps to deploy this 3-tier AWS architecture in your own AWS account using Terraform.

📋 Prerequisites
Before you begin, ensure you have the following installed and configured:

AWS CLI configured with your credentials (aws configure).

Terraform CLI (v1.0+) installed.

Git installed.

📥 1. Clone the Repository
Bash
git clone https://github.com/Ibad84671/secvault-aws-terraform.git
cd secvault-aws-terraform
⚙️ 2. Configure Environment Variables
Create a terraform.tfvars file in the root directory to supply your database secrets safely (do not commit this file):

Terraform
db_username = "admin"
db_password = "YourSecurePassword123!"
🏗️ 3. Initialize & Deploy Infrastructure
Initialize Terraform working directory:

Bash
terraform init
Validate configuration & check plan:

Bash
terraform validate
terraform plan
Apply and provision resources on AWS:

Bash
terraform apply
(Type yes when prompted to confirm deployment)

🌐 4. Access the Application
Once terraform apply finishes, copy the alb_dns_name output from your terminal and open it in your web browser:

Plaintext
http://<alb_dns_name>
🧹 5. Destroy & Clean Up Resources
To avoid ongoing AWS charges after testing, destroy all provisioned infrastructure:

Bash
terraform destroy
(Type yes when prompted to confirm cleanup)