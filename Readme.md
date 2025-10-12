# 🚀 Banking App Infrastructure on AWS using Terraform

This repository contains Terraform code to provision a complete AWS infrastructure for deploying a containerized **Banking Application** using **ECS Fargate**, **ECR**, and **Application Load Balancer (ALB)**.

---

## 📦 Infrastructure Overview

### Components Provisioned
| Resource | Description |
|-----------|--------------|
| **ECR Repository** | Stores Docker images for the Banking App. |
| **ECS Cluster** | Hosts the application tasks using Fargate. |
| **IAM Roles** | Provides ECS tasks permissions for AWS services. |
| **Application Load Balancer (ALB)** | Routes external HTTP/HTTPS traffic to ECS services. |
| **Target Group & Listeners** | Routes requests to containers on port 8080. |
| **ECS Task Definition** | Defines the container configuration (image, ports, environment variables). |
| **ECS Service** | Manages the running tasks and ensures availability. |
| **RDS (PostgreSQL)** | Backend database for the banking application. |
| **Security Groups** | Controls network access between ALB, ECS, and RDS. |

---

## 🏗️ High Level Diagram

        Internet
           |
        ALB (HTTP/HTTPS)
           |
      Target Group (8080)
           |
     ECS Service (Fargate)
     /            \
Container 1      Container 2
(bank-app)       (bank-app)
           |
        RDS/Postgres

---

## ⚙️ Prerequisites

Before running Terraform:

1. **Install Tools**
   - [Terraform](https://developer.hashicorp.com/terraform/downloads)
   - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - [Docker](https://www.docker.com/)

2. **AWS Credentials**
   - Set up credentials in GitHub Actions Secrets or your local AWS CLI:
     ```bash
     aws configure
     ```

3. **Required Variables**
   Create a `terraform.tfvars` file or use environment variables:
   ```hcl
   project         = "banking-app"
   ecr_repo        = "banking-app-repo"
   db_username     = "admin"
   db_password     = "securepassword"
   image_tag       = "latest"
   desired_count   = 1
   enable_alb_access_logs = false
   acm_cert_arn    = ""
   alb_logs_bucket = ""
---
🧩 File Structure
.
├── main.tf
├── variables.tf
├── ecr_ecs_alb.tf
├── vpc.tf
├── db.tf
├── outputs.tf
├── terraform.tfvars
└── .github/workflows/
    └── terraform.yml

---

🚀 Deployment Steps
1️⃣ Initialize Terraform
terraform init

2️⃣ Plan the Infrastructure
terraform plan

3️⃣ Apply the Configuration
terraform apply -auto-approve

4️⃣ Destroy Infrastructure (if needed)
terraform destroy -auto-approve

---