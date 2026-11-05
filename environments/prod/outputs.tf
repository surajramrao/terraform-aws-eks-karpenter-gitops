output "cluster_endpoint"             { value = module.eks_karpenter.cluster_endpoint }
output "karpenter_queue_name"         { value = module.eks_karpenter.karpenter_queue_name }
output "karpenter_node_iam_role_name" { value = module.eks_karpenter.karpenter_node_iam_role_name }
