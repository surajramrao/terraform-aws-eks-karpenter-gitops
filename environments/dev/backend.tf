terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }

  backend "s3" {
    bucket       = "org-platform-tfstate-dev-ap-south-1"
    key          = "eks-karpenter/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    kms_key_id   = "alias/terraform-state-lock-dev"
    use_lockfile = true
  }
}
