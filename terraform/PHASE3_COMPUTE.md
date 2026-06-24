# BookMyScreen Terraform Phase 3: Compute Infrastructure

**Status:** Phase 3 - Compute Infrastructure (Application Testing)  
**Created:** 2024  
**Author:** AWS Solutions Architect  

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Pre-Deployment Requirements](#pre-deployment-requirements)
- [Deployment Guide](#deployment-guide)
- [Testing the Application](#testing-the-application)
- [Outputs & Access](#outputs--access)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Next Phases](#next-phases)

---

## Overview

**Phase 3** deploys the compute infrastructure required to test the complete BookMyScreen application within the VPC.

### What Phase 3 Creates ✅

- ✅ Internet-facing Application Load Balancer (Multi-AZ)
- ✅ Frontend Target Group (port 5173)
- ✅ Backend Target Group (port 9000)
- ✅ HTTP Listener with routing rules
- ✅ Frontend EC2 Instance (Ubuntu, t3.micro)
- ✅ Backend EC2 Instance (Ubuntu, t3.micro)
- ✅ Target group attachments for both instances

### What Phase 3 Does NOT Create ❌

- ❌ Auto Scaling Groups
- ❌ Launch Templates
- ❌ Bastion Host
- ❌ Lambda functions
- ❌ CloudFront
- ❌ Route53
- ❌ WAF
- ❌ Secrets Manager
- ❌ CloudWatch
- ❌ DocumentDB
- ❌ ElastiCache Redis
- ❌ S3
- ❌ IAM Roles
- ❌ Additional Security Groups

---

## Architecture

### Network Design

```
┌──────────────────────────────────────────────────────────────┐
│                        INTERNET (0.0.0.0/0)                  │
│                                                              │
│  HTTPS:80 → bms-alb-sg (allows 0.0.0.0/0)                  │
└────┬─────────────────────────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────────────────────────────┐
│         Application Load Balancer (ALB)                     │
│  ┌──────────────────────────────────────────────────┐      │
│  │ Public Subnet A (10.0.1.0/24)                    │      │
│  │ Public Subnet B (10.0.2.0/24)                    │      │
│  │                                                   │      │
│  │ Internet-facing, Multi-AZ, Security Group: ALB   │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  Listener Configuration:                                   │
│  ├─ Port 80 (HTTP)                                        │
│  │  ├─ Default Rule: / → Frontend Target Group:5173      │
│  │  └─ Rule 1: /api/* → Backend Target Group:9000        │
└────┬──────────────────────────────┬───────────────────────┘
     │ Forwards to port 5173         │ Forwards to port 9000
     │ (Frontend SG)                 │ (Backend SG)
     │                              │
     ▼                              ▼
┌─────────────────────┐    ┌──────────────────────┐
│ Frontend EC2        │    │ Backend EC2          │
│ ┌─────────────────┐ │    │ ┌──────────────────┐ │
│ │Private App A    │ │    │ │Private App A     │ │
│ │(10.0.11.0/24)  │ │    │ │(10.0.11.0/24)   │ │
│ │                 │ │    │ │                  │ │
│ │ Ubuntu Server   │ │    │ │ Ubuntu Server    │ │
│ │ t3.micro        │ │    │ │ t3.micro         │ │
│ │ Port: 5173      │ │    │ │ Port: 9000       │ │
│ │ React/Vite      │ │    │ │ Node.js/Express  │ │
│ │                 │ │    │ │ PM2 Ready        │ │
│ │ SG: Frontend    │ │    │ │ SG: Backend      │ │
│ │ No Public IP    │ │    │ │ No Public IP     │ │
│ └─────────────────┘ │    │ └──────────────────┘ │
└─────────────────────┘    └──────────────────────┘
        ▲                           ▲
        │                           │
        │ Registered with TG        │ Registered with TG
        └───────────────────────────┘
```

### Component Details

#### Application Load Balancer

```
Name:                  bms-alb
Type:                  Application Load Balancer
Scheme:                internet-facing
Subnets:               Public A (10.0.1.0/24), Public B (10.0.2.0/24)
Security Group:        bms-alb-sg (from Phase 2)
Availability:          Multi-AZ (2 AZs)
```

#### Target Groups

**Frontend Target Group**
```
Name:                  bms-frontend-tg
Port:                  5173 (Vite dev server / production)
Protocol:              HTTP
Health Check Path:     /
Health Check Interval: 30 seconds
Healthy Threshold:     2 consecutive successes
Unhealthy Threshold:   2 consecutive failures
```

**Backend Target Group**
```
Name:                  bms-backend-tg
Port:                  9000 (Node.js/Express API)
Protocol:              HTTP
Health Check Path:     /api/v1
Health Check Interval: 30 seconds
Healthy Threshold:     2 consecutive successes
Unhealthy Threshold:   2 consecutive failures
```

#### EC2 Instances

**Frontend Instance**
```
Name:                  bms-frontend
AMI:                   ami-07a00cf47dbbc844c (Ubuntu 24.04 LTS)
Instance Type:         t3.micro
Subnet:                Private App A (10.0.11.0/24)
Security Group:        bms-frontend-sg
Public IP:             Disabled (private subnet)
Storage:               20 GB gp3
IMDSv2:                Required
Key Pair:              bookmyscreen-dev (user-provided)
User Data:             Git, Node.js, Curl installation
```

**Backend Instance**
```
Name:                  bms-backend
AMI:                   ami-07a00cf47dbbc844c (Ubuntu 24.04 LTS)
Instance Type:         t3.micro
Subnet:                Private App A (10.0.11.0/24)
Security Group:        bms-backend-sg
Public IP:             Disabled (private subnet)
Storage:               20 GB gp3
IMDSv2:                Required
Key Pair:              bookmyscreen-dev (user-provided)
User Data:             Git, Node.js, PM2, Curl installation
```

---

## Pre-Deployment Requirements

### 1. Create EC2 Key Pair

You MUST create an EC2 Key Pair before deploying Phase 3.

**Using AWS CLI:**
```bash
aws ec2 create-key-pair \
  --key-name bookmyscreen-dev \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > bookmyscreen-dev.pem

# Set secure permissions
chmod 400 bookmyscreen-dev.pem
```

**Using AWS Console:**
1. Go to EC2 → Key Pairs
2. Click "Create Key Pair"
3. Name: `bookmyscreen-dev`
4. Format: PEM
5. Click "Create Key Pair"
6. Download and save the .pem file

### 2. Verify Phase 1 & Phase 2 Deployment

```bash
# Navigate to dev environment
cd terraform/environments/dev

# Check existing state
terraform state list

# Should show networking and security resources
# module.networking.aws_vpc.main
# module.networking.aws_subnet.public_a
# module.security.aws_security_group.alb
# etc.
```

### 3. Update terraform.tfvars with Key Pair Name

Edit `environments/dev/terraform.tfvars`:

```hcl
# PHASE 3: COMPUTE CONFIGURATION
key_name = "bookmyscreen-dev"  # ← Replace with your actual key pair name
```

---

## Deployment Guide

### Step 1: Validate Configuration

```bash
cd terraform/environments/dev

# Validate Terraform configuration
terraform validate

# Expected: Success! The configuration is valid.
```

### Step 2: Plan Deployment

```bash
# Generate execution plan
terraform plan -out=phase3-tfplan

# Expected output should show:
# Plan: 9 to add, 0 to change, 0 to destroy
#
# 9 new resources:
#   - aws_lb (ALB)
#   - aws_lb_target_group (2)
#   - aws_lb_listener
#   - aws_lb_listener_rule
#   - aws_instance (2)
#   - aws_lb_target_group_attachment (2)
```

**CRITICAL VALIDATION:**
- ✅ No changes to existing networking resources
- ✅ No changes to existing security groups
- ✅ Only 9 new resources created

### Step 3: Review the Plan

```bash
# Review plan output
terraform plan -out=phase3-tfplan

# Check for any resource modifications
# Should show "0 to change"
```

### Step 4: Apply Deployment

```bash
# Deploy Phase 3 infrastructure
terraform apply phase3-tfplan

# Expected output:
# Apply complete! Resources: 9 added, 0 changed, 0 destroyed.
```

### Step 5: Retrieve Outputs

```bash
# Display all outputs
terraform output

# Key outputs to note:
# - alb_dns_name: The URL to access the application
# - frontend_instance_id: Frontend EC2 instance ID
# - backend_instance_id: Backend EC2 instance ID
# - application_access_url: Direct URL
```

---

## Testing the Application

### 1. Wait for Health Checks

After deployment, wait **2-3 minutes** for ALB health checks to pass.

**Monitor health status:**
```bash
# Get ALB details
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw frontend_target_group_arn) \
  --region ap-south-1 \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]' \
  --output table
```

**Expected output:**
```
i-xxxxxxxxxx    healthy
i-yyyyyyyyy     healthy
```

### 2. Access the Application

```bash
# Get ALB DNS name
ALB_URL=$(terraform output -raw alb_dns_name)

echo "Application URL: http://$ALB_URL"

# Open in browser or test with curl
curl -v http://$ALB_URL/
curl -v http://$ALB_URL/api/v1
```

### 3. Test Frontend Load

```bash
# Access frontend (should return HTML)
curl -I http://<alb-dns-name>/

# Expected response: HTTP/1.1 200 OK
```

### 4. Test Backend API

```bash
# Access backend health check
curl -I http://<alb-dns-name>/api/v1

# Expected: Backend should respond with 200-299 status
```

### 5. Verify Application Functionality

Once you have the ALB URL:
1. Open browser: `http://<alb-dns-name>`
2. Test BookMyScreen features:
   - User signup
   - OTP verification
   - Login
   - Movie listing
   - Show selection
   - Seat selection
   - Booking flow

---

## Outputs & Access

### Key Outputs

```bash
terraform output alb_dns_name
# Returns: bms-alb-123456789.ap-south-1.elb.amazonaws.com

terraform output frontend_instance_id
# Returns: i-0abc123def456

terraform output backend_instance_id
# Returns: i-0xyz789def123

terraform output application_access_url
# Returns: http://bms-alb-123456789.ap-south-1.elb.amazonaws.com
```

### Testing Information

```bash
terraform output testing_information

# Returns comprehensive testing details:
{
  "alb_dns_name" = "bms-alb-xxx.ap-south-1.elb.amazonaws.com"
  "alb_url" = "http://bms-alb-xxx.ap-south-1.elb.amazonaws.com"
  "frontend_health_check" = "http://bms-alb-xxx.ap-south-1.elb.amazonaws.com/"
  "backend_health_check" = "http://bms-alb-xxx.ap-south-1.elb.amazonaws.com/api/v1"
  "api_endpoint" = "http://bms-alb-xxx.ap-south-1.elb.amazonaws.com/api"
  "frontend_instance_id" = "i-xxx"
  "frontend_private_ip" = "10.0.11.50"
  "backend_instance_id" = "i-yyy"
  "backend_private_ip" = "10.0.11.51"
  "alb_health_check_delay" = "2-3 minutes"
}
```

### SSH Access to Instances

```bash
# Get instance IPs
FRONTEND_IP=$(terraform output -raw frontend_private_ip)
BACKEND_IP=$(terraform output -raw backend_private_ip)

# SSH requires either:
# 1. VPN connection to VPC
# 2. Systems Manager Session Manager
# 3. EC2 Instance Connect

# Via Systems Manager (easiest):
aws ssm start-session \
  --target i-<instance-id> \
  --region ap-south-1
```

---

## Verification

### 1. Verify ALB Deployment

```bash
aws elbv2 describe-load-balancers \
  --region ap-south-1 \
  --query 'LoadBalancers[?LoadBalancerName==`bms-alb`]' \
  --output table
```

### 2. Verify Target Groups

```bash
aws elbv2 describe-target-groups \
  --region ap-south-1 \
  --query 'TargetGroups[?starts_with(TargetGroupName, `bms-`)]' \
  --output table
```

### 3. Verify EC2 Instances

```bash
aws ec2 describe-instances \
  --region ap-south-1 \
  --filters "Name=tag:Project,Values=bms" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PrivateIpAddress]' \
  --output table
```

### 4. Verify Target Health

```bash
# Frontend targets
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw frontend_target_group_arn) \
  --region ap-south-1 \
  --output table

# Backend targets
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw backend_target_group_arn) \
  --region ap-south-1 \
  --output table
```

### 5. Test ALB Routing

```bash
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test default route (→ Frontend)
curl -v http://$ALB_DNS/ 2>&1 | grep -E "HTTP|<"

# Test API route (→ Backend)
curl -v http://$ALB_DNS/api/v1 2>&1 | grep -E "HTTP|{"
```

---

## Troubleshooting

### Issue: Instances show "unhealthy" status

**Symptoms:** Health check failing, instances marked unhealthy

**Diagnosis:**
1. Check ALB security group allows inbound on 80/443
2. Verify EC2 security groups allow ALB SG traffic
3. Check user data execution: `curl http://localhost:5173` on Frontend

**Solution:**
```bash
# SSH into instance and check
aws ssm start-session --target i-<instance-id> --region ap-south-1

# Check if port is listening
sudo netstat -tlnp | grep 5173  # Frontend
sudo netstat -tlnp | grep 9000  # Backend

# Check user data logs
cat /var/log/cloud-init-output.log
```

### Issue: Cannot access ALB from browser

**Symptoms:** Connection timeout or refused

**Diagnosis:**
1. Wait 2-3 minutes for ALB startup
2. Verify ALB is in "active" state
3. Check security group allows port 80

**Solution:**
```bash
# Check ALB state
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[0].State.Code' \
  --region ap-south-1

# Should be: active

# Check listener
aws elbv2 describe-listeners \
  --load-balancer-arn $(terraform output -raw alb_arn) \
  --region ap-south-1 \
  --output table
```

### Issue: Application returns 502 Bad Gateway

**Symptoms:** ALB is working but application returns 502

**Diagnosis:**
1. Instances may not be running services yet
2. User data may still be executing

**Solution:**
```bash
# Wait longer for user data completion
aws ec2 describe-instances \
  --instance-ids <instance-id> \
  --query 'Reservations[0].Instances[0].[State.Name,StateTransitionReason]' \
  --region ap-south-1

# Check user data logs on instance
aws ssm start-session --target <instance-id> --region ap-south-1
tail -f /var/log/cloud-init-output.log
```

---

## Next Phases

### Phase 3 Beta: Application Deployment

Modify EC2 user data to deploy actual application:

```bash
# Clone repository
git clone https://github.com/kajapathy-k/book-my-screen.git
cd book-my-screen
git checkout aws-dev

# Frontend deployment
cd bms-frontend
npm install
npm run build
npm run dev

# Backend deployment (separate instance)
cd bms-backend
npm install
npm run dev  # or PM2 start
```

### Phase 4: Data Layer

Add:
- [ ] Amazon DocumentDB cluster
- [ ] Amazon ElastiCache Redis cluster
- [ ] Database connectivity from Backend EC2

### Phase 5: Advanced Features

Add:
- [ ] AWS Secrets Manager for credentials
- [ ] IAM roles for EC2 instances
- [ ] AWS KMS for encryption
- [ ] CloudWatch logging

### Phase 6: Production Hardening

Add:
- [ ] Auto Scaling Groups
- [ ] Launch Templates
- [ ] Multi-AZ EC2 deployment
- [ ] Bastion host for management
- [ ] AWS WAF on ALB

---

## File Structure

```
terraform/
├── modules/
│   ├── networking/           # Phase 1 ✅
│   ├── security/             # Phase 2 ✅
│   └── compute/              # Phase 3 ✅
│       ├── main.tf           # ALB, target groups, EC2
│       ├── variables.tf       # Input variables
│       ├── outputs.tf         # Output values
│       ├── locals.tf          # Local values
│       ├── user_data_frontend.sh
│       └── user_data_backend.sh
│
├── environments/
│   └── dev/
│       ├── main.tf           # All 3 modules
│       ├── variables.tf       # Dev variables
│       ├── terraform.tfvars   # Dev values
│       └── outputs.tf         # All outputs
│
└── PHASE3_COMPUTE.md         # This file
```

---

## Cleanup

To destroy Phase 3 resources:

```bash
cd terraform/environments/dev

# Plan destruction
terraform plan -destroy

# Destroy (keeping Phase 1 & 2)
terraform destroy -target=module.compute

# Or destroy everything
terraform destroy
```

---

**Status:** Phase 3 Complete and Ready for Testing  
**Next:** Phase 3 Beta - Deploy actual BookMyScreen application

---

**Created:** 2024  
**Last Updated:** 2024  
**Author:** AWS Solutions Architect - BookMyScreen Project
