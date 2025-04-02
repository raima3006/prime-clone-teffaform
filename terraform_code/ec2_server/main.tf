terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
}

provider "aws" {
  region = var.region_name
}

#STEP1: CREATE SG
resource "aws_security_group" "my-sg" {
  name        = "JENKINS-SERVER-SG-NEW"
  description = "JEnkins Server Ports"

  # Port 22 is required for SSH Access
  ingress {
    description = "SSH Port"    # Describes the rule for SSH access
    from_port   = 22            # Starting port (22 for SSH)
    to_port     = 22            # Ending port (22 for SSH)
    protocol    = "tcp"         # Starting port (22 for SSH)
    cidr_blocks = ["0.0.0.0/0"] ## Allows access from anywhere (public access)
  }

  # HTTP (Port 80) - Allows access to web servers
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the public (any IP)
  }

  # HTTPS (Port 443) - Allows secure web traffic
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the public (any IP)
  }

  # Port 5432 is required for Postgres
  ingress {
    description = "Allow PostgreSQL traffic"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your machine's IP
  }

  #Port 2379-2380 is required for etcd-cluster
  ingress {
    description = "Allow etc-cluster Port"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana (Port 3000) - Monitoring dashboard
  ingress {
    description = "Allow Grafana traffic"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to public (adjust for security)
  }

  # KubeAPIServer (Port 6443) - Kubernetes API server access
  ingress {
    description = "Allow Kubernetes API Server traffic"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to public (adjust for security)
  }

  # Jenkins (Port 8080) - CI/CD automation platform
  #ingress {aws iam list-policies --scope Local
  ingress {
    description = "Allow Jenkins traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to public (adjust for security)
  }

  # Port 9000 is required for SonarQube
  ingress {
    description = "SonarQube Port"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 9090 is required for Prometheus
  ingress {
    description = "Prometheus Port"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 9100 is required for Prometheus metrics server
  ingress {
    description = "Prometheus Metrics Port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 10250-10260 is required for K8s
  ingress {
    description = "K8s Ports"
    from_port   = 10250
    to_port     = 10260
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 30000-32767 is required for NodePort
  ingress {
    description = "K8s NodePort"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define outbound rules to allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all protocols (TCP, UDP, ICMP, etc.)
    cidr_blocks = ["0.0.0.0/0"]


  }
}

#STEP2: CREAT EC2 USING PEM & SG
resource "aws_instance" "my-ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
  depends_on                  = [aws_security_group.my-sg]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = var.server_name
  }
 

# USING REMOTE-EXEC PROVISIONER TO INSTALL PACKAGES
  provisioner "remote-exec" {
    # ESTABLISHING SSH CONNECTION WITH EC2
    connection {
      type        = "ssh"
      private_key = file("./key.pem") # replace with your key-name 
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [
      # Install AWS CLI
      # Ref: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
      "sudo apt install unzip -y",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",

      # Install Docker
      # Ref: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo chmod 777 /var/run/docker.sock",
      "docker --version",

      # Install SonarQube (as container)
      "docker run -d --name sonar -p 9000:9000 sonarqube:lts-community",

      # Install Trivy
      # Ref: https://aquasecurity.github.io/trivy/v0.18.3/installation/
      "sudo apt-get install -y wget apt-transport-https gnupg",
      "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null",
      "echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main' | sudo tee -a /etc/apt/sources.list.d/trivy.list",
      "sudo apt-get update -y",
      "sudo apt-get install trivy -y",

      # Install Kubectl
      # Ref: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#kubectl-install-update
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl",
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl.sha256",
      "sha256sum -c kubectl.sha256",
      "openssl sha1 -sha256 kubectl",
      "chmod +x ./kubectl",
      "mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH",
      "echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc",
      "sudo mv $HOME/bin/kubectl /usr/local/bin/kubectl",
      "sudo chmod +x /usr/local/bin/kubectl",
      "kubectl version --client",

      # Install Helm
      # Ref: https://helm.sh/docs/intro/install/
      # Ref (for .tar.gz file): https://github.com/helm/helm/releases
      "wget https://get.helm.sh/helm-v3.16.1-linux-amd64.tar.gz",
      "tar -zxvf helm-v3.16.1-linux-amd64.tar.gz",
      "sudo mv linux-amd64/helm /usr/local/bin/helm",
      "helm version",

      # Install ArgoCD
      # Ref: https://argo-cd.readthedocs.io/en/stable/cli_installation/
      "VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)",
      "curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64",
      "sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd",
      "rm argocd-linux-amd64",

      # Install Java 17
      # Ref: https://www.rosehosting.com/blog/how-to-install-java-17-lts-on-ubuntu-20-04/
      "sudo apt update -y",
      "sudo apt install openjdk-17-jdk openjdk-17-jre -y",
      "java -version",

      # Install Jenkins
      # Ref: https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",

      # Get Jenkins initial login password
      "ip=$(curl -s ifconfig.me)",
      "pass=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)",

      # Output
      "echo 'Access Jenkins Server here --> http://'$ip':8080'",
      "echo 'Jenkins Initial Password: '$pass''",
      "echo 'Access SonarQube Server here --> http://'$ip':9000'",
      "echo 'SonarQube Username & Password: admin'",
    ]
  }
}


#STEP3: GET EC2 USER NAME AND PUBLIC IP
output "SERVER-SSH-ACCESS" {
  value = "ubuntu@${aws_instance.my-ec2.public_ip}"
}

# STEP4: GET EC2 PUBLIC IP  (for external access)
output "PUBLIC-IP" {
  value = aws_instance.my-ec2.public_ip
}

# STEP5: GET EC2 PRIVATE IP  
output "PRIVATE-IP" {
  value = aws_instance.my-ec2.private_ip
}


