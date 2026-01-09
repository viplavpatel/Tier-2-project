

# VPC
resource "aws_vpc" "web_vpc" { //vpc is like virtual network in Azure
  cidr_block = "10.0.0.0/16" //denote a private network
  
  tags = {
    Name = "web-vpc"
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.web_vpc.id // Reference to the VPC created above
  cidr_block        = "10.0.1.0/24" //denote a subnet within the VPC
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true  # Automatically assign public IP so as to access from internet
  
  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway (allows internet access)
resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web_vpc.id
  
  tags = {
    Name = "web-igw"
  }
}

# Route Table (routes traffic to internet gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.web_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0" //route for all internet traffic
    gateway_id = aws_internet_gateway.web_igw.id
  }
  
  tags = {
    Name = "public-route-table"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group (like NSG in Azure)
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.web_vpc.id
  
  # Inbound rule - SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] //allow from anywhere
  }
  
  # Inbound rule - HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
  # Outbound rule - Allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web-security-group"
  }
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  key_name = "linuxkey" //SSH key already created in AWS
  
  
  # User data script (runs on first boot)
  user_data = templatefile("${path.module}/../../../app/user_data.sh", { //referencing user_data.sh file to run bash script
    dockerfile_content = file("${path.module}/../../../app/Dockerfile") //read Dockerfile content
    html_content       = file("${path.module}/../../../app/index.html") //read index.html content
  })
  
  tags = {
    Name        = "WebServer"
    Environment = "Production"
  }
  
  
}