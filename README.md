# CoBank Cloud Platform

**End-to-End Cloud-Native Deployment with Terraform, Ansible, EKS & GitOps**

---

## 📌 Overview

**CoBank Cloud Platform** is a production-style cloud-native application deployed on **AWS EKS**, using **Terraform** for infrastructure provisioning, **Ansible** for build and deployment automation, and **ArgoCD** for GitOps-based continuous delivery.

This repository demonstrates:

* Infrastructure as Code (IaC)
* Secure container builds & scanning
* Kubernetes deployments
* GitOps workflow
* CI/CD on AWS

> **Note:** This project uses a demo tech stack (AWS, Terraform, Ansible, EKS, ArgoCD). The principles demonstrated—CI/CD, GitOps, IaC, and containerized deployments—can be applied to other environments.

---

## 🧱 Architecture (High Level)

```
Developer
   |
   v
GitHub Repo
   |
   v
CI/CD Pipeline (Jenkins / GitHub Actions)
   |
   +--> Terraform → AWS VPC + EKS
   |
   +--> Ansible → Build, Scan, Push Images
   |
   v
Amazon ECR
   |
   v
EKS Cluster
   |
   +--> ArgoCD (GitOps)
   |
   v
Frontend + Backend (Istio Ingress)
```

---

## 📂 Repository Structure

```
.
├── ansible/                # Build, scan, push, deploy
├── infra/terraform/        # AWS VPC + EKS
├── apps/                   # Frontend & Backend code
├── k8s/                    # Kubernetes manifests
├── gitops/argo/            # ArgoCD applications
├── istio-1.28.2/           # Istio configuration
├── Jenkinsfile             # Optional Jenkins CI pipeline
├── docker-compose.yml      # Local dev
└── README.md               # This file
```

---

## 🖥️ Step 0: Local Deployment & Testing (Optional)

Run and test the application locally **without AWS**.

### Prerequisites for Local Deployment

* Docker & Docker Compose
* Python 3.10+
* Minikube or kind (optional, for Kubernetes testing)
* kubectl

### Build and Run with Docker Compose

```bash
docker-compose build
docker-compose up
```

*Frontend:* [http://localhost:3000](http://localhost:3000)
*Backend:* [http://localhost:5000](http://localhost:5000)

> Docker Compose simulates the deployed environment locally.

### Run Kubernetes Locally (Optional)

1. Start a local cluster:

```bash
minikube start
```

2. Configure kubectl:

```bash
kubectl config use-context minikube
```

3. Apply manifests:

```bash
kubectl apply -f k8s/
```

4. Check pods & services:

```bash
kubectl get pods
kubectl get svc
```

5. Access frontend via NodePort:

```bash
minikube service frontend
```

### Test Application

* Verify frontend and backend endpoints.
* Optional: run backend tests:

```bash
cd apps/backend
pytest
```

> Local deployment is ideal for **fast iteration and testing** before cloud deployment.

---

## ✅ Prerequisites (Cloud Deployment)

Install locally:

* AWS CLI
* Terraform **>= 1.5**
* Ansible
* Docker
* kubectl
* Python 3.10+
* Trivy (optional)
* istioctl (optional)
* argocd CLI (optional)

Configure AWS credentials:

```bash
aws configure
```

---

## 🏗️ STEP 1: Provision Infrastructure (Terraform)

### 1. Go to Terraform directory

```bash
cd infra/terraform
```

### 2. Initialize Terraform

```bash
terraform init -upgrade
```

### 3. Plan Infrastructure

```bash
terraform plan \
  -var "cluster_name=my-eks-cluster" \
  -var "region=us-east-1"
```

### 4. Apply Infrastructure

```bash
terraform apply \
  -var "cluster_name=my-eks-cluster" \
  -var "region=us-east-1"
```

### What Terraform Creates

* VPC (public + private subnets)
* Internet/NAT Gateways
* EKS cluster
* Managed node groups
* IAM roles & security groups

---

## 🔑 STEP 2: Configure kubectl for EKS

```bash
aws eks update-kubeconfig \
  --name my-eks-cluster \
  --region us-east-1
```

Verify:

```bash
kubectl get nodes
```

---

## 🔧 STEP 3: Ansible – Build, Scan, Push & Deploy

### 1. Create Python Virtual Environment

```bash
python3 -m venv ansible-venv
source ansible-venv/bin/activate
pip install ansible requests docker
```

### 2. Inventory (already included)

`ansible/inventory/localhost.yml`

```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
```

### 3. Run Ansible Playbook

```bash
cd ansible
ansible-playbook main.yml \
  -i inventory/localhost.yml \
  -e aws_region=us-east-1 \
  -e cluster_name=my-eks-cluster \
  -e app_namespace=cobank
```

### What Ansible Does

1. Validates environment
2. Generates immutable image tags (Git SHA)
3. Authenticates Docker to Amazon ECR
4. Builds frontend & backend images
5. Scans images with Trivy
6. Pushes images to ECR
7. Applies Kubernetes manifests
8. Verifies pods & services

---

## 🌀 STEP 4: GitOps with ArgoCD

### 1. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Deploy ArgoCD Application

```bash
kubectl apply -f gitops/argo/application.yaml
```

ArgoCD will:

* Watch the Git repo
* Automatically sync Kubernetes manifests
* Reconcile drift

---

## 🌐 STEP 5: Access the Application

### Check Pods

```bash
kubectl get pods -n cobank
```

### Port-forward Istio Ingress

```bash
kubectl port-forward \
  svc/istio-ingressgateway 8080:80 \
  -n istio-system
```

Access:

* Frontend: [http://localhost:8080](http://localhost:8080)

---

## 🔁 STEP 6: CI/CD on AWS

### Option A: Jenkins (Traditional CI)

1. Deploy Jenkins on EC2 or EKS
2. Install plugins: Docker, Terraform, Ansible, AWS CLI
3. Add AWS credentials
4. Create a Multibranch Pipeline
5. Jenkins uses `Jenkinsfile`

Pipeline stages:

* Checkout
* Terraform Init/Apply
* Ansible Build & Deploy
* ECR Push
* EKS Deploy

---

### Option B: GitHub Actions (Modern CI)

Typical workflow:

* Trigger on push
* Terraform deploy infra
* Ansible build & push
* ArgoCD sync cluster

(Recommended for production)

---

## 🔄 Full End-to-End Flow

```text
Git Push
   ↓
CI Pipeline
   ↓
Terraform → AWS Infra
   ↓
Ansible → Build & Push Images
   ↓
ECR
   ↓
EKS
   ↓
ArgoCD (GitOps)
   ↓
Running Application
```

---

## 🧹 Cleanup

Destroy everything:

```bash
cd infra/terraform
terraform destroy \
  -var "cluster_name=my-eks-cluster" \
  -var "region=us-east-1"
```

---

## 🛡️ Best Practices Used

* Immutable Docker images
* Git-based versioning
* Infrastructure as Code
* GitOps deployment model
* Security scanning (Trivy)
* Separation of infra & app layers

---

## 📌 Summary

This repository demonstrates a **real-world AWS production workflow** using:

* Terraform → Infrastructure
* Ansible → Build & Deploy
* Kubernetes → Runtime
* ArgoCD → GitOps
* Jenkins/GitHub Actions → CI/CD

It is designed to be **scalable, auditable, cloud-native**, with optional **local deployment** for quick testing and review.
