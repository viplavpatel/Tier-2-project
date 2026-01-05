# AWS EC2 Web Application Deployment with Terraform

A complete Infrastructure as Code (IaC) solution to deploy a custom web application on AWS EC2 using Terraform, Docker, and GitHub Actions CI/CD.

## 🚀 Features

- **Automated Infrastructure Deployment**: VPC, Subnet, Internet Gateway, Security Groups, and EC2 instance
- **Custom Docker Image**: Build and deploy your own containerized web application
- **CI/CD Pipeline**: Automated deployment and updates using GitHub Actions
- **Public Access**: Web application accessible via public IP with HTTP
- **Free Tier Eligible**: Uses t3.micro instance (AWS free tier)

## 📋 Prerequisites

- AWS Account with appropriate permissions
- AWS Access Key ID and Secret Access Key
- Terraform installed locally (optional, GitHub Actions has it)
- Git installed
- Docker knowledge (basic)

## 🏗️ Architecture

```
Internet
    ↓
Internet Gateway
    ↓
VPC (10.0.0.0/16)
    ↓
Public Subnet (10.0.1.0/24)
    ↓
Security Group (Ports 22, 80)
    ↓
EC2 Instance (t3.micro)
    ↓
Docker Container (nginx + custom app)
    ↓
Your Web Application
```

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── deploy.yml              # Full infrastructure deployment
│       └── update-container.yml    # Quick Docker updates
├── app/
│   ├── Dockerfile                  # Docker image definition
│   ├── index.html                  # Your web application
│   └── user_data.sh                # EC2 startup script template
├── modules/
│   ├── compute/
│   │   └── virtualMachines/
│   │       ├── main.tf             # EC2 and networking resources
│   │       ├── variables.tf        # Module variables
│   │       └── outputs.tf          # Module outputs
│   ├── general/
│   │   └── resourcegroup/
│   └── networking/
│       └── vnet/
├── providers.tf                    # AWS provider configuration
├── main.tf                         # Root module
├── variables.tf                    # Root variables
├── terraform.tfvars                # Variable values
└── README.md                       # This file
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/godsofhell/vnet-peering.git
cd vnet-peering
```

### 2. Configure AWS Credentials

**Option A: Environment Variables**
```powershell
$env:AWS_ACCESS_KEY_ID="your-access-key"
$env:AWS_SECRET_ACCESS_KEY="your-secret-key"
$env:AWS_DEFAULT_REGION="eu-west-2"
```

**Option B: AWS CLI**
```bash
aws configure
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy to AWS
terraform apply
```

### 4. Access Your Application

After deployment completes:
```bash
terraform output instance_public_ip
```

Visit: `http://<public-ip>`

## 🔧 Customization

### Modify the Web Application

Edit `app/index.html` with your custom HTML:
```html
<!DOCTYPE html>
<html>
<head>
    <title>My App</title>
</head>
<body>
    <h1>Hello World!</h1>
</body>
</html>
```

### Customize Docker Image

Edit `app/Dockerfile` to change the base image or add dependencies:
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
# Add more customizations here
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Change AWS Region

Edit `providers.tf`:
```hcl
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}
```

Also update the availability zone in `modules/compute/virtualMachines/main.tf`:
```hcl
availability_zone = "us-east-1a"
```

### Modify Instance Type

Edit `modules/compute/virtualMachines/main.tf`:
```hcl
instance_type = "t3.small"  # Upgrade from t3.micro
```

## 🔄 CI/CD with GitHub Actions

### Setup

1. **Add AWS Credentials to GitHub Secrets:**
   - Go to repository **Settings** → **Secrets and variables** → **Actions**
   - Add `AWS_ACCESS_KEY_ID`
   - Add `AWS_SECRET_ACCESS_KEY`

2. **Push to Main Branch:**
```bash
git add .
git commit -m "Deploy infrastructure"
git push origin main
```

### Workflows

#### Full Deployment (`deploy.yml`)
- **Triggers**: Push to `main` branch
- **Duration**: ~2-3 minutes
- **Action**: Creates/updates entire infrastructure
- **Use for**: Initial deployment, infrastructure changes

#### Quick Update (`update-container.yml`)
- **Triggers**: Changes to `app/` folder
- **Duration**: ~30 seconds
- **Action**: Updates Docker container only
- **Use for**: App updates (HTML, CSS, Dockerfile changes)

## 📊 Resources Created

| Resource | Type | Purpose |
|----------|------|---------|
| VPC | `aws_vpc` | Isolated network (10.0.0.0/16) |
| Subnet | `aws_subnet` | Public subnet (10.0.1.0/24) |
| Internet Gateway | `aws_internet_gateway` | Internet connectivity |
| Route Table | `aws_route_table` | Traffic routing |
| Security Group | `aws_security_group` | Firewall rules (ports 22, 80) |
| EC2 Instance | `aws_instance` | t3.micro server |

## 🔒 Security Considerations

### Current Setup (Development)
- ⚠️ SSH (port 22) open to `0.0.0.0/0` (entire internet)
- ⚠️ HTTP (port 80) open to `0.0.0.0/0`
- ⚠️ No HTTPS/SSL encryption
- ⚠️ No VPN or bastion host

### Production Recommendations
1. **Restrict SSH Access**: Limit to your IP address
   ```hcl
   cidr_blocks = ["your-ip/32"]  # Your IP only
   ```

2. **Add HTTPS**: Use AWS Certificate Manager + Application Load Balancer

3. **Use Bastion Host**: For SSH access instead of direct exposure

4. **Enable CloudWatch Logs**: Monitor and audit access

5. **Implement IAM Roles**: Instead of hardcoded credentials

## 🛠️ Maintenance

### View Logs
```bash
# SSH into instance
ssh -i linuxkey.pem ec2-user@<public-ip>

# Check Docker logs
sudo docker logs web

# Check running containers
sudo docker ps
```

### Update Application
```bash
# Edit app files
vim app/index.html

# Commit and push
git add app/
git commit -m "Update homepage"
git push origin main
```
GitHub Actions will automatically update the container!

### Destroy Infrastructure
```bash
# Remove all AWS resources
terraform destroy

# Or destroy specific resource
terraform destroy -target=module.instance.aws_instance.web_server
```

## 💰 Cost Estimate

**AWS Free Tier (12 months):**
- EC2 t3.micro: 750 hours/month FREE
- Data Transfer: 100 GB/month FREE
- VPC, Security Groups: FREE

**After Free Tier:**
- EC2 t3.micro: ~$7.50/month (running 24/7)
- Data Transfer: $0.09/GB (outbound)

## 🐛 Troubleshooting

### Connection Refused
- Wait 2-3 minutes after deployment for user_data script to complete
- Check Security Group allows port 80
- Verify instance has public IP: `terraform output instance_public_ip`

### SSH Connection Failed
- Ensure you have the correct key pair (`linuxkey.pem`)
- Check permissions: `chmod 400 linuxkey.pem` (Linux/Mac)
- Verify Security Group allows port 22 from your IP

### Terraform Errors
```bash
# Refresh state
terraform refresh

# Re-initialize
terraform init -upgrade

# View detailed logs
export TF_LOG=DEBUG
terraform plan
```

### Docker Container Not Running
```bash
# SSH into EC2
ssh -i linuxkey.pem ec2-user@<public-ip>

# Check user_data logs
sudo cat /var/log/cloud-init-output.log

# Rebuild container manually
cd /home/ec2-user/app
sudo docker build -t mywebapp:latest .
sudo docker run -d -p 80:80 --name web mywebapp:latest
```

## 📚 Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

**godsofhell**
- GitHub: [@godsofhell](https://github.com/godsofhell)
- Repository: [vnet-peering](https://github.com/godsofhell/vnet-peering)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

---

**Built with ❤️ using Terraform, Docker, and AWS**
