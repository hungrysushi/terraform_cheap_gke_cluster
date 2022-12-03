variable "project_id" {
  description = "GCP project ID"
}

variable "name" {
  description = "GKE cluster name"
}

# control plane config
variable "regional_cluster" {
  description = "Create as regional cluster instead of zonal"
}

variable "kube_version" {
  description = "Kubernetes version"
  default = "1.25"
}

variable "region" {
  description = "Region"
}

variable "zones" {
  description = "Availability zones for cluster"
}

variable "create_networking" {
  description = "Whether to create networking resources for the cluster or use existing"
}

variable "http_load_balancing" {
  description = "Enable HTTP load balancing"
}

variable "vpc" {
  description = "Cluster VPC name, either existing or to create"
}

variable "subnet" {
  description = "Cluster subnet name, either existing or to create"
}

variable "ip_range_pods" {
  description = "IP range name for pods"
}

variable "ip_range_services" {
  description = "IP range name for services"
}

variable "logging_service" {
  default = "none"
}

variable "monitoring_service" {
  default = "none"
}

# node config
variable "ingress_pool" {
  description = "Configuration for cheap ingress pool"
  default = {
    config = {
      name = "ingress-pool"
      auto_upgrade = true

      autoscaling = false
      min_count = 1
      max_count = 1
      max_surge = 0
      max_unavailable = 1

      machine_type = "e2-micro"
      preemptible = true
      disk_size_gb = 10
    },
    tags = [
      "ingress-pool",
    ],
    taints = [
      {
        key = "dedicated"
        value = "ingress"
        effect = "NO_SCHEDULE"
      }
    ],
    metadata = {}
  }
}

variable "additional_pools" {
  description = "Extra node pool configurations"
  default = [
    {
      name = "default-pool"
      auto_upgrade = true

      autoscaling = false
      min_count = 1
      max_count = 10
      max_surge = 0
      max_unavailable = 1

      machine_type = "e2-standard-2"
      preemptible = true
      disk_size_gb = 20
    }
  ]
}

variable "additional_pools_tags" {
  description = "Extra node pool tags"
  default = {}
}

variable "additional_pools_taints" {
  description = "Extra pool taints"
  default = {}
}

variable "additional_pools_metadata" {
  description = "Extra node pool metadata"
  default = {}
}

variable "all_pools_tags" {
  description = "Tags for all pools"
  default = []
}

variable "all_pools_taints" {
  description = "Taints for all pools"
  default = []
}

variable "all_pools_metadata" {
  description = "Metadata for all pools"
  default = {}
}

variable "compute_address_name" {
  description = "Name for reserved IP address"
  default = "node-ingress"
}

variable "kubeip_node_selector" {
  description = "Name of pool on which to run kubeip"
  default = ""
}

variable "enable_argocd" {
  description = "Install ArgoCD chart"
  default = false
}

variable "argocd_version" {
  description = "Chart version to deploy"
  default = "5.14.1"
}

variable "argocd_values" {
  description = "YAML values to use with chart"
}
