# Highly Available Load-Balanced Web App with Auto Scaling 🚀

## 📋 Project Overview

This project demonstrates the design and implementation of a highly available, fault-tolerant web application infrastructure on AWS using raw **Terraform** (without third-party modules).

The infrastructure features a custom Virtual Private Cloud (VPC), public subnets distributed across separate Availability Zones, an Application Load Balancer (ALB), and an Auto Scaling Group (ASG) hosting dynamic web servers that showcase real-time server metadata via EC2 Instance Metadata Service (**IMDSv2**).

---

## 🏗️ Architecture Components

| Component | Description |
|-----------|-------------|
| **Custom VPC** | Network isolation with a `10.20.0.0/16` CIDR block |
| **High Availability** | 2 Public Subnets in different Availability Zones (`us-east-1a` & `us-east-1b`) |
| **Application Load Balancer (ALB)** | Public entry point routing traffic to active instances |
| **Auto Scaling Group (ASG)** | Dynamically scales instances (Min: 2, Desired: 2, Max: 4) based on health checks and traffic |
| **Security Isolation** | Tiered Security Groups — EC2 instances accept HTTP traffic *only* from the ALB |
| **Secure Metadata** | Enforced **IMDSv2** for secure EC2 metadata token access |

---

## 📂 Project Structure

```text
terraform-alb-asg-assignment/
├── main.tf           # Main infrastructure definitions (VPC, ALB, ASG)
├── data.tf           # Data sources for fetching the latest Amazon Linux 2023 AMI
├── variables.tf      # Configuration variables
├── outputs.tf        # Important deployment output values (ALB DNS, VPC ID)
├── providers.tf      # AWS Provider definition
├── backend.tf        # Remote S3 state storage and DynamoDB locking configuration
├── index.html        # Pre-styled HTML template for the web application
└── user_data.sh      # Bash bootstrap script for OS setup and IMDSv2 token replacement
```

---

## 🚀 Deployment Steps

**1. Initialize Terraform & Backend**
```bash
terraform init
```

**2. Validate Configuration**
```bash
terraform validate
```

**3. Review Execution Plan**
```bash
terraform plan
```

**4. Deploy Infrastructure**
```bash
terraform apply -auto-approve
```

---

## 🛠️ Verification & Testing

After `apply` completes successfully:

1. Copy the **ALB DNS Name** from the Terminal outputs.
2. Open the URL in your browser — you'll see the web UI displaying the currently connected server's metadata.
3. **Refresh the page** several times. You'll notice the `Instance ID` and `Private IP` change dynamically, confirming the load balancer is successfully distributing traffic between the two running instances in round-robin fashion.
