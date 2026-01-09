output "region" {
  value       = var.region
  description = "AWS region"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Public subnet IDs"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint"
}

output "cluster_oidc_issuer_url" {
  value       = module.eks.oidc_provider
  description = "OIDC provider ARN (used for IRSA)"
}

output "backend_ecr_repo_url" {
  value       = aws_ecr_repository.backend.repository_url
  description = "ECR repository URL for the backend image"
}

output "frontend_ecr_repo_url" {
  value       = aws_ecr_repository.frontend.repository_url
  description = "ECR repository URL for the frontend image"
}
