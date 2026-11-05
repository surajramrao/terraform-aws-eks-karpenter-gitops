provider "aws" {
  region = var.aws_region

  # Enterprise Account Isolation: Explicitly assume the Prod Account execution role
  assume_role {
    role_arn     = var.execution_role_arn
    session_name = "Terraform-EKS-Prod"
  }

  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
      Project     = "terraform-aws-eks-karpenter-gitops"
    }
  }
}
