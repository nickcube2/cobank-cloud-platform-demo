variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
  default     = "cobank-eks"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {
    Environment = "dev"
    Project     = "cobank"
  }
}
