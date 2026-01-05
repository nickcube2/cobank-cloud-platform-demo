# CoBank Cloud Platform

A production-grade, secure, observable, GitOps-driven cloud-native application on AWS EKS.

## Features
- React Frontend + Node.js Backend
- Deployed on AWS EKS via Terraform
- Istio Service Mesh with mTLS
- GitOps with ArgoCD
- Monitoring: Prometheus + Grafana
- Security: Network Policies, Trivy scans
- Backups: Velero

## Quick Start
1. Provision infra: `cd infra/terraform && terraform apply`
2. Install ArgoCD and apply `gitops/argo/application.yaml`
3. Access app via Istio Gateway
