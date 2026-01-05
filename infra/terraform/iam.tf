module "eks_iam" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "~> 5.0"

  cluster_name = module.eks.cluster_name

  # Additional roles (e.g., for Velero, External Secrets)
  create_iam_role_for_velero = true  # Assuming S3 bucket for backups
}

# EKS cluster IAM roles are handled by the EKS module
