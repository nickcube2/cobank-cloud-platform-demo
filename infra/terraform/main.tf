############################################
# Availability Zones
############################################
data "aws_availability_zones" "available" {
  state = "available"
}

############################################
# VPC
############################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = var.tags
}

############################################
# EKS Cluster
############################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # IMPORTANT: allow access from local machine
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  enable_irsa = true

  ##########################################
  # EKS Access Entry (IAM → Kubernetes)
  ##########################################
  access_entries = {
    nickcube_admin = {
      principal_arn = "arn:aws:iam::405449137534:user/nickcube"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  ##########################################
  # Managed Node Group
  ##########################################
  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 5
      desired_size = 3

      instance_types = ["t3.medium"]
    }
  }
}

############################################
# ECR Repositories
############################################
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

############################################
# Kubernetes Provider (USE KUBECONFIG)
############################################
provider "kubernetes" {
  config_path = "~/.kube/config"
}

############################################
# Helm Provider (USE KUBECONFIG)
############################################
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

############################################
# ArgoCD (Helm)
############################################
resource "helm_release" "argocd" {
  depends_on = [module.eks]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.ingress.enabled"
    value = "false"
  }
}

