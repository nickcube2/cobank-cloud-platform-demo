# Terraform (AWS)

This Terraform config provisions:

- A VPC with public + private subnets (and NAT)
- An EKS cluster with a managed node group
- Two ECR repositories:
  - `cobank-backend`
  - `cobank-frontend`

## Prereqs

- Terraform >= 1.5
- AWS credentials configured (e.g., `aws configure`)
- `kubectl` and `awscli` installed

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

After apply, configure kubeconfig:

```bash
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
kubectl get nodes
```

## Notes

- This config uses public EKS endpoint by default (`cluster_endpoint_public_access=true`). For production, consider private endpoint access, restricted CIDRs, and private-only clusters.
- For remote state, add an S3 backend (recommended for teams).
