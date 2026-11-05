terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80.0"
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Network Hardening: Private access always enabled; public restricted by CIDR
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Modern EKS Access Entries (No implicit creator admin permissions)
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = false

  access_entries = {
    platform_admin = {
      principal_arn = var.admin_principal_arn
      type          = "STANDARD"
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

  # Control Plane Audit Logging & KMS Envelope Encryption for K8s Secrets
  cluster_enabled_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_kms_key                = true
  kms_key_enable_default_policy = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  eks_managed_node_groups = {
    core_system = {
      name            = "core-system-mng"
      use_name_prefix = true
      instance_types  = var.system_node_instance_types

      min_size     = var.system_node_min_size
      max_size     = var.system_node_max_size
      desired_size = var.system_node_min_size

      # Enforce IMDSv2 with hop limit 1
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }

      # Encrypted gp3 root disk
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      labels = {
        "CriticalAddonsOnly" = "true"
        "node-role"          = "system"
      }

      taints = {
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.31.0"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true

  # EKS Pod Identity for Karpenter Controller
  enable_pod_identity             = true
  create_pod_identity_association = true
  namespace                       = "kube-system"
  service_account                 = "karpenter"

  # Encrypt Spot Interruption SQS Queue
  enable_spot_termination   = true
  queue_managed_sse_enabled = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
