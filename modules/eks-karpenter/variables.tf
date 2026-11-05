variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes minor version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for control plane and worker nodes"
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks permitted to access the public EKS API endpoint"
  type        = list(string)
  default     = []
}

variable "admin_principal_arn" {
  description = "IAM Role ARN granted EKS ClusterAdmin access via EKS Access Entries"
  type        = string
}

variable "system_node_instance_types" {
  description = "Instance types for core system Managed Node Group (CoreDNS, Karpenter controller)"
  type        = list(string)
  default     = ["m6i.large", "m6a.large"]
}

variable "system_node_min_size" {
  description = "Minimum number of core system nodes"
  type        = number
  default     = 2
}

variable "system_node_max_size" {
  description = "Maximum number of core system nodes"
  type        = number
  default     = 4
}
