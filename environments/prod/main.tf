module "vpc" {
  source = "../../modules/vpc"

  cluster_name       = var.cluster_name
  environment        = "prod"
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
}

module "eks_karpenter" {
  source = "../../modules/eks-karpenter"

  cluster_name                         = var.cluster_name
  cluster_version                      = var.cluster_version
  vpc_id                               = module.vpc.vpc_id
  private_subnets                      = module.vpc.private_subnet_ids
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  admin_principal_arn                  = var.admin_principal_arn
  system_node_instance_types           = var.system_node_instance_types
  system_node_min_size                 = var.system_node_min_size
  system_node_max_size                 = var.system_node_max_size
}
