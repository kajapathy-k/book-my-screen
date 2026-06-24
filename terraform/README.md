# BookMyScreen Terraform Infrastructure

Modular, production-grade Infrastructure as Code for the BookMyScreen (BookMyShow Clone) application, deployed across AWS Mumbai region (ap-south-1).

## 🚀 Quick Links

- **Phase 1:** [Networking Foundation](QUICKSTART.md)
- **Phase 2:** [Security Architecture](PHASE2_SECURITY.md)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [Best Practices](#best-practices)
- [Future Phases](#future-phases)
- [Troubleshooting](#troubleshooting)

---

## Overview

This is a **Multi-Phase** Terraform project for BookMyScreen cloud infrastructure.

### Current Phase

**Phase 1 ✅ (Complete):** Networking Foundation  
**Phase 2 ✅ (Complete):** Security Architecture

### Phase 1 Scope

✅ **Created:**
- VPC with DNS support enabled
- Internet Gateway
- Elastic IP for NAT Gateway
- NAT Gateway
- 6 Subnets (2 per tier, across 2 Availability Zones)
- Route tables with appropriate routing rules
- Enterprise-grade tagging

### Phase 2 Scope

✅ **Created:**
- 5 Security Groups (ALB, Frontend, Backend, DocumentDB, Redis)
- Least privilege inbound/outbound rules
- Zero direct internet exposure to backend/databases
- Complete audit trail ready
- 18 comprehensive output values

❌ **NOT in Phase 1-2:**
- EC2 instances
- Application Load Balancer
- Amazon DocumentDB
- Amazon ElastiCache
- Amazon S3
- AWS Secrets Manager
- IAM roles
- CloudWatch/Monitoring
- AWS WAF
- Route53
- CloudFront

These will be implemented in **Phase 3+**.

---

## Architecture

### Network Design

```
┌─────────────────────────────────────────────────────────────────┐
│                    BookMyScreen Network (10.0.0.0/16)          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────── INTERNET ──────────────────────┐   │
│  │                                                        │   │
│  │  ┌─────────────────────────────────────────┐           │   │
│  │  │   Internet Gateway (IGW)                │           │   │
│  │  └─────────────────┬───────────────────────┘           │   │
│  │                    │ Route: 0.0.0.0/0 → IGW           │   │
│  │                    │                                   │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │  PUBLIC LAYER (Route: 0.0.0.0/0 → IGW)       │    │   │
│  │  │                                               │    │   │
│  │  │  ┌──────────────┐  ┌──────────────┐          │    │   │
│  │  │  │ Public Sub A │  │ Public Sub B │          │    │   │
│  │  │  │ 10.0.1.0/24  │  │ 10.0.2.0/24 │          │    │   │
│  │  │  │ AZ: A        │  │ AZ: B       │          │    │   │
│  │  │  │              │  │             │          │    │   │
│  │  │  │ - ALB        │  │ - ALB (HA)  │          │    │   │
│  │  │  │ - NAT GW     │  │             │          │    │   │
│  │  │  └──────────────┘  └──────────────┘          │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  │                    │ NAT GW Route: 0.0.0.0/0 → NAT     │   │
│  │                    │                                   │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │  PRIVATE APP LAYER (Route: 0.0.0.0/0 → NAT)  │    │   │
│  │  │                                               │    │   │
│  │  │  ┌──────────────┐  ┌──────────────┐          │    │   │
│  │  │  │Private App A │  │Private App B │          │    │   │
│  │  │  │ 10.0.11.0/24 │  │ 10.0.12.0/24│          │    │   │
│  │  │  │ AZ: A        │  │ AZ: B       │          │    │   │
│  │  │  │              │  │             │          │    │   │
│  │  │  │ - EC2 Front  │  │ - EC2 Front │          │    │   │
│  │  │  │ - EC2 Back   │  │ - EC2 Back  │          │    │   │
│  │  │  └──────────────┘  └──────────────┘          │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  │                    │ No Internet Route                 │   │
│  │                    │                                   │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │  PRIVATE DATA LAYER (No Internet Route)       │    │   │
│  │  │                                               │    │   │
│  │  │  ┌──────────────┐  ┌──────────────┐          │    │   │
│  │  │  │Private Data A│  │Private Data B│          │    │   │
│  │  │  │ 10.0.21.0/24 │  │ 10.0.22.0/24│          │    │   │
│  │  │  │ AZ: A        │  │ AZ: B       │          │    │   │
│  │  │  │              │  │             │          │    │   │
│  │  │  │ - DocumentDB │  │ - DocumentDB│          │    │   │
│  │  │  │ - ElastiCache│  │ - ElastiCache          │    │   │
│  │  │  └──────────────┘  └──────────────┘          │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  │                                                        │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### CIDR Allocation Strategy

| Layer | Subnet | AZ | CIDR Block | IPs | Purpose |
|-------|--------|----|-----------|----|---------|
| **Public** | A | ap-south-1a | 10.0.1.0/24 | 254 | ALB, NAT GW |
| **Public** | B | ap-south-1b | 10.0.2.0/24 | 254 | ALB (HA), NAT GW (Future) |
| **Private App** | A | ap-south-1a | 10.0.11.0/24 | 254 | EC2 Frontend/Backend |
| **Private App** | B | ap-south-1b | 10.0.12.0/24 | 254 | EC2 Frontend/Backend (HA) |
| **Private Data** | A | ap-south-1a | 10.0.21.0/24 | 254 | DocumentDB, ElastiCache |
| **Private Data** | B | ap-south-1b | 10.0.22.0/24 | 254 | DocumentDB, ElastiCache (HA) |

**Remaining Space:** 10.0.3-10.0.0/24, 10.0.13-20.0/24, 10.0.23-30.0/24 (180 /24 subnets available for future growth)

---

## Prerequisites

### Required Tools

1. **Terraform** (>= 1.0)
   ```bash
   # Verify installation
   terraform version
   ```

2. **AWS CLI** (>= 2.0)
   ```bash
   # Verify installation
   aws --version
   ```

3. **AWS Account** with appropriate permissions:
   - VPC creation
   - Subnet creation
   - Internet Gateway creation
   - NAT Gateway creation
   - Elastic IP allocation
   - Route Table management

### AWS Credentials

Configure AWS credentials using one of the following methods:

**Option 1: AWS CLI Configuration**
```bash
aws configure
```

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

**Option 3: IAM Credentials File**
```bash
# ~/.aws/credentials
[default]
aws_access_key_id = your-access-key
aws_secret_access_key = your-secret-key
```

### Backend Storage Setup

Before running Terraform, create the S3 bucket and DynamoDB table for remote state:

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket bms-terraform-state-dev \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket bms-terraform-state-dev \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket bms-terraform-state-dev \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create DynamoDB table
aws dynamodb create-table \
  --table-name bms-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

---

## Getting Started

### 1. Clone the Repository

```bash
cd c:\bms\book-my-screen
```

### 2. Navigate to the Environment Directory

```bash
cd terraform/environments/dev
```

### 3. Initialize Terraform

```bash
terraform init
```

This command:
- Downloads AWS provider plugins
- Initializes the working directory
- Configures remote backend for state management

### 4. Review the Plan

```bash
terraform plan -out=tfplan
```

This command:
- Analyzes your Terraform configuration
- Shows what resources will be created
- Outputs the plan to a file for review

### 5. Review the Output

Examine the output carefully. You should see resources being created:
- VPC
- Internet Gateway
- 6 Subnets
- NAT Gateway
- Elastic IP
- 3 Route Tables

---

## Deployment

### Apply the Terraform Configuration

```bash
terraform apply tfplan
```

This will:
- Create all networking resources in AWS
- Output resource IDs and details
- Store state remotely in S3

### Expected Deployment Time

Typically **3-5 minutes** to create all resources.

### Verify Deployment

```bash
# Describe the VPC
aws ec2 describe-vpcs --region ap-south-1 --query 'Vpcs[?CidrBlock==`10.0.0.0/16`]'

# List all subnets in the VPC
aws ec2 describe-subnets --region ap-south-1 --filters "Name=vpc-id,Values=vpc-xxxxx"

# Check NAT Gateway status
aws ec2 describe-nat-gateways --region ap-south-1
```

---

## Outputs

After successful deployment, Terraform outputs the following:

### Key IDs (For Phase 2+ Modules)

```
vpc_id                              = "vpc-xxxxx"
internet_gateway_id                 = "igw-xxxxx"
nat_gateway_id                      = "nat-xxxxx"
elastic_ip_allocation_id            = "eipalloc-xxxxx"
```

### Subnet IDs

```
# Public Subnets
public_subnet_a_id                  = "subnet-xxxxx"
public_subnet_b_id                  = "subnet-xxxxx"

# Private App Subnets
private_app_subnet_a_id             = "subnet-xxxxx"
private_app_subnet_b_id             = "subnet-xxxxx"

# Private Data Subnets
private_data_subnet_a_id            = "subnet-xxxxx"
private_data_subnet_b_id            = "subnet-xxxxx"
```

### Route Table IDs

```
public_route_table_id               = "rtb-xxxxx"
private_app_route_table_id          = "rtb-xxxxx"
private_data_route_table_id         = "rtb-xxxxx"
```

### View All Outputs

```bash
terraform output
```

### Export Outputs to JSON

```bash
terraform output -json > outputs.json
```

---

## Best Practices

### 1. State Management

- **Never commit** `terraform.tfstate` to version control
- **Enable versioning** on S3 backend bucket
- **Enable encryption** at rest
- **Use DynamoDB** for state locking
- **Restrict IAM** access to state bucket

### 2. Code Organization

```
terraform/
├── modules/              # Reusable modules
├── environments/         # Environment-specific configs
├── versions.tf          # Provider versions
├── backend.tf           # Backend configuration
└── README.md            # Documentation
```

### 3. Naming Convention

All resources follow this pattern:
```
{project}-{resource-type}{-details}
```

Example: `bms-vpc`, `bms-public-subnet-az-a`, `bms-nat-gw`

### 4. Tagging Strategy

Every resource includes:
- **Name:** Descriptive identifier
- **Environment:** dev/staging/production
- **Project:** bms
- **ManagedBy:** Terraform

### 5. Variable Validation

All CIDR blocks are validated using Terraform's `validation` block to prevent invalid configurations.

### 6. Multi-AZ Strategy

- Resources are distributed across 2 AZs
- Availability Zones are dynamically selected (not hardcoded)
- Supports zero-downtime updates

---

## Future Phases

### Phase 1.5: High Availability Enhancement

- [ ] Deploy NAT Gateway in both AZs
- [ ] Add route to second NAT Gateway in private app subnets

### Phase 3: Compute & Load Balancing

- [ ] Launch Templates
- [ ] Auto Scaling Groups
- [ ] EC2 instances (Frontend)
- [ ] EC2 instances (Backend)
- [ ] Application Load Balancer
- [ ] ALB Target Groups

### Phase 4: Data Layer

- [ ] Amazon DocumentDB
- [ ] Amazon ElastiCache Redis
- [ ] Database subnet groups
- [ ] Parameter groups

### Phase 5: Advanced Networking

- [ ] VPC Flow Logs
- [ ] VPC Endpoints (S3, Secrets Manager)
- [ ] Network ACLs
- [ ] VPC Peering (Multi-region)

### Phase 6: Security & Monitoring

- [ ] AWS Secrets Manager
- [ ] AWS KMS
- [ ] CloudWatch Logs
- [ ] CloudWatch Alarms
- [ ] AWS CloudTrail
- [ ] AWS WAF
- [ ] Security Hub
- [ ] GuardDuty

### Phase 7: CDN & DNS

- [ ] Route53 Hosted Zones
- [ ] CloudFront Distribution
- [ ] ACM Certificates
- [ ] S3 Bucket (static assets)

### Phase 8: CI/CD

- [ ] GitHub Actions
- [ ] Automated deployments
- [ ] Infrastructure testing

---

## Troubleshooting

### Issue: "No default VPC"

**Solution:** Ensure you're using the correct region. The VPC will be created in `ap-south-1`.

### Issue: "Insufficient capacity in AZ"

**Solution:** AWS may have insufficient capacity. Try:
```bash
# Re-run apply
terraform apply tfplan

# Or destroy and recreate
terraform destroy
terraform apply
```

### Issue: "IAM permissions denied"

**Solution:** Ensure your IAM user/role has these permissions:
- `ec2:CreateVpc`
- `ec2:CreateSubnet`
- `ec2:CreateInternetGateway`
- `ec2:CreateNatGateway`
- `ec2:AllocateAddress`
- `ec2:CreateRouteTable`

### Issue: "State lock timeout"

**Solution:** DynamoDB table may be locked. Check:
```bash
# List items in DynamoDB table
aws dynamodb scan --table-name bms-terraform-locks --region ap-south-1

# If necessary, delete the lock item manually
```

### View Terraform Logs

```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply
```

---

## Module Structure

### Networking Module

**Location:** `modules/networking/`

**Files:**
- `main.tf` - VPC, subnets, gateways, route tables
- `variables.tf` - Input variables
- `outputs.tf` - Exported values for other modules
- `locals.tf` - Local values and naming conventions

**Key Resources:**
- VPC
- Internet Gateway
- Elastic IP
- NAT Gateway
- 6 Subnets (3 layers × 2 AZs)
- 3 Route Tables with associations

---

## Support & Documentation

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)

---

## License

This Terraform code is part of the BookMyScreen project. All rights reserved.

---

## Changelog

### v2.0.0 (Phase 2)
- ✅ Five security groups for application tiers
- ✅ Least privilege inbound/outbound rules
- ✅ Zero direct internet exposure to backend/databases
- ✅ Complete audit trail ready
- ✅ 18 comprehensive output values
- ✅ Production-grade security architecture

### v1.0.0 (Phase 1)
- ✅ Initial networking foundation
- ✅ VPC with 3-tier subnet architecture
- ✅ Multi-AZ setup across ap-south-1a and ap-south-1b
- ✅ NAT Gateway for private app outbound access
- ✅ Enterprise-grade tagging and naming
- ✅ Complete documentation

---

**Created:** 2024  
**Last Updated:** 2024  
**Author:** AWS Solutions Architect - BookMyScreen Project
