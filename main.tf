terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.44.1"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "4.44.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.7.1"
    }
  }
}

provider "kubectl" {
  # Configuration options
  host = "https://${module.gke.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host = "https://${module.gke.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host = "https://${module.gke.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

locals {
  vpc = var.create_networking ? google_compute_network.vpc[0].name : var.vpc
  subnet = var.create_networking ? google_compute_subnetwork.subnet[0].name : var.subnet
  ip_range_pods = var.create_networking ? "${var.name}-pod-range" : var.ip_range_pods
  ip_range_services = var.create_networking ? "${var.name}-service-range" : var.ip_range_services
}

module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google"

  name  = var.name
  project_id = var.project_id

  kubernetes_version = var.kube_version

  regional = var.regional_cluster
  region = var.region
  zones = var.zones
  network = local.vpc
  subnetwork = local.subnet
  ip_range_pods = local.ip_range_pods
  ip_range_services = local.ip_range_services
  http_load_balancing = var.http_load_balancing

  logging_service = var.logging_service
  monitoring_service = var.monitoring_service

  remove_default_node_pool = true
  node_pools = local.node_pools
  node_pools_tags = local.node_pools_tags
  node_pools_taints = local.node_pools_taints
  node_pools_metadata = local.node_pools_metadata
  grant_registry_access = true
}

locals {
  node_pools = concat(
    [ var.ingress_pool.config ],
    var.additional_pools,
  )

  node_pools_tags = merge(
    { all = var.all_pools_tags },
    { (var.ingress_pool.config.name) = var.ingress_pool.tags },
    var.additional_pools_tags,
  )

  node_pools_taints = merge(
    { all = var.all_pools_taints },
    { (var.ingress_pool.config.name) = var.ingress_pool.taints },
    var.additional_pools_taints,
  )

  node_pools_metadata = merge(
    { all = var.all_pools_metadata },
    { (var.ingress_pool.config.name) = var.ingress_pool.metadata },
    var.additional_pools_metadata,
  )
}
