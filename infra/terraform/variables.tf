variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "cobank-eks"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "github_repo_url" {
  description = "Your GitHub repo URL for ArgoCD (e.g., https://github.com/yourusername/cobank-cloud-platform.git)"
  type        = string
}
