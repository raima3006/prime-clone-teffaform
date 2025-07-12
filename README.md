DevOps Architecture Diagram
   
   +-----------+
   |  GitHub   | <-- Source Code (Node.js Clone)
   +-----------+
        |
        v
+---------------+       +-----------------+
|   Jenkins CI  |<----->|     SonarQube   |  <-- Code quality & gate
+---------------+       +-----------------+
        |
        v
  +-------------+
  |    NPM      | <-- Node.js Build
  +-------------+
        |
        v
+---------------+       +--------------+
|     Trivy     |<----->|   Docker     | <-- Image build
+---------------+       +--------------+
        |                    |
        v                    v
  +-----------------------------+
  |      AWS ECR (Private)      | <-- Stores built image
  +-----------------------------+
        |
        v
  +---------------------+
  |    ArgoCD + EKS     | <-- Deployment to Kubernetes
  +---------------------+
        |
        v
+-----------------+     +----------------+
|  Prometheus     | --> |   Grafana      | <-- Monitoring dashboard
+-----------------+     +----------------+

* Infrastructure provisioned by Terraform (EC2, Security Groups, etc.)
* AWS CLI used throughout for Jenkins ↔ AWS communication
* Jenkins credentials securely stored for AWS and SonarQube integrations
