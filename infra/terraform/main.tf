module "vpc" {
  source = "./modules/vpc"  # Or use official module if preferred
  vpc_cidr = var.vpc_cidr
  cluster_name = var.cluster_name
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = "~> 20.0"
  cluster_name = var.cluster_name
  cluster_version = "1.31"  # Latest as of 2026

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 5
      desired_size = 3
      instance_types = ["t3.medium"]
    }
  }

  # Enable OIDC for IAM roles
  enable_irsa = true
}

resource "aws_ecr_repository" "frontend" {
  name                 = "cobank-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "cobank-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Provider for Kubernetes (post-EKS)
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

# Install ArgoCD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true

  set {
    name  = "server.ingress.enabled"
    value = "false"  # Expose via Istio later
  }
}
