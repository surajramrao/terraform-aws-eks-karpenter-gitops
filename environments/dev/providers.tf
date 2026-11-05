provider "aws" {
  region = var.aws_region

  # Enterprise Account Isolation: Explicitly assume the Dev Account execution role
  assume_role {
    role_arn     = var.execution_role_arn
    session_name = "Terraform-EKS-Dev"
  }

  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "terraform-aws-eks-karpenter-gitops"
    }
  }
}
