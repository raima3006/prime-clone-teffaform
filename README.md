# 🎬 Amazon Prime Video Clone - Fully Automated CI/CD with AWS DevOps

Welcome to the **Amazon Prime Video Clone** repository! This project is a hands-on, fully automated DevOps implementation of a cloud-native application, using the best-in-class DevOps tools and AWS services.

> 🔧 Built using Node.js • 🐳 Containerized with Docker • 🚀 Automated with Jenkins • ☁️ Deployed on AWS (ECR, EKS) • 🔍 Monitored via Prometheus & Grafana

---

## 📌 Project Highlights

- 🚀 **CI/CD Pipeline** implemented with Jenkins
- 🧪 **SonarQube** for code quality and bug detection
- 📦 **NPM** for building the Node.js application
- 🛡️ **Trivy** vulnerability scanner integrated
- 🐳 Dockerized application artifacts
- 📤 Push to **AWS ECR** (Elastic Container Registry)
- ☸️ Deployed via **ArgoCD** to **Amazon EKS**
- 📈 **Prometheus + Grafana** monitoring
- 🔧 **Terraform** for Infrastructure-as-Code (IaC)

---

## 🔁 End-to-End DevOps Pipeline Overview


GitHub → Jenkins → SonarQube → NPM Build → Trivy Scan → Docker Build → AWS ECR → ArgoCD → EKS → Prometheus/Grafana

---

## 🔨 Tools & Technologies
| Tool           | Purpose                                |
| -------------- | -------------------------------------- |
| **GitHub**     | Source code version control            |
| **Jenkins**    | CI/CD orchestration                    |
| **SonarQube**  | Static code analysis & quality gates   |
| **NPM**        | Package & build manager for Node.js    |
| **Trivy**      | Vulnerability scanning (Aqua Security) |
| **Docker**     | Containerization                       |
| **AWS ECR**    | Container image registry               |
| **ArgoCD**     | GitOps-based Kubernetes deployment     |
| **Amazon EKS** | Kubernetes cluster on AWS              |
| **Terraform**  | Infrastructure provisioning (IaC)      |
| **Prometheus** | Resource & application monitoring      |
| **Grafana**    | Visual dashboards for monitoring data  |


---

## 📂 Repository Structure
├── terraform/              # EC2 + Jenkins + Security Group provisioning
├── kubernetes/             # Deployment and service YAMLs
├── pipeline-scripts/       # Jenkins scripted pipelines
├── Dockerfile              # Docker build instructions
├── .gitignore
├── README.md
└── ...

---

## ⚙️ Prerequisites
✅ AWS Free Tier Account
✅ AWS CLI configured on your local machine
✅ EC2 key-pair (.pem file)
✅ Terraform installed
✅ Docker & Jenkins installed locally or on EC2
✅ VS Code or any code editor

---

## 🚀 Getting Started
1. Clone the repo
git clone https://github.com/raima3006/amazon-prime-devops.git
cd amazon-prime-devops

2. Configure AWS & Terraform
Create an IAM user with Admin access
Generate access_key and secret_key
Run:
aws configure

3. Provision Infrastructure
cd terraform/
terraform init
terraform apply -auto-approve

4. Access Jenkins
Use the public IP from the output to log into Jenkins
Configure credentials and plugins as per documentation

5. Run CI/CD Pipelines
Use provided scripted pipelines under pipeline-scripts/
Trigger build jobs from Jenkins GUI














