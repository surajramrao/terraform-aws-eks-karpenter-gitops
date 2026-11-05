variable "cluster_name" {
  description = "Name of the EKS cluster for Karpenter subnet discovery tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (true for dev cost savings, false for prod HA)"
  type        = bool
  default     = false
}
