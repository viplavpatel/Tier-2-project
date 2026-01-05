#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

# Create app directory
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Create Dockerfile from template variable
cat > Dockerfile <<'DOCKEREOF'
${dockerfile_content}
DOCKEREOF

# Create index.html from template variable
cat > index.html <<'HTMLEOF'
${html_content}
HTMLEOF

# Build Docker image
sudo docker build -t mywebapp:latest .

# Run container
sudo docker run -d -p 80:80 --name web mywebapp:latest
