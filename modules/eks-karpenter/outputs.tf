output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Control Plane API Endpoint"
  value       = module.eks.cluster_endpoint
}

output "karpenter_queue_name" {
  description = "SQS Queue name for Karpenter spot interruption handling"
  value       = module.karpenter.queue_name
}

output "karpenter_node_iam_role_name" {
  description = "IAM Role name attached to Karpenter EC2 NodeClasses"
  value       = module.karpenter.node_iam_role_name
}
