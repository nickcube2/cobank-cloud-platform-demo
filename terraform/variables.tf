variable "project" {
  description = "Project/name prefix used for resources"
  type        = string
  default     = "cobank"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Additional tags applied to resources"
  type        = map(string)
  default     = {}
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cheaper) instead of one per AZ"
  type        = bool
  default     = true
}

# EKS
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cobank-eks"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS endpoint is publicly accessible"
  type        = bool
  default     = true
}

# Node group
variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "node_desired_capacity" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_ami_type" {
  description = "EKS node AMI type (e.g., AL2_x86_64, BOTTLEROCKET_x86_64)"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_disk_size_gb" {
  description = "Node root volume size in GiB"
  type        = number
  default     = 50
}

# ECR
variable "ecr_keep_last_images" {
  description = "How many images to keep in ECR lifecycle policy"
  type        = number
  default     = 50
}
