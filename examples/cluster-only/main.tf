locals {
  project_id = "PROJECT_ID"
  name = "CLUSTER_NAME"
  region = "CLUSTER_REGION"
  zone = "CLUSTER_ZONE"
  kube_version = "1.24.9-gke.3200"
}

module "cheap_cluster" {
  source = "../../"

  project_id = local.project_id
  name = local.name

  kube_version = local.kube_version
  regional_cluster = false
  region = local.region
  zones = [ local.zone ]
  http_load_balancing = false
  create_networking = true
  vpc = local.name
  subnet = local.name
  ip_range_pods = "${local.name}-pods"
  ip_range_services = "${local.name}-services"
  logging_service = "none"
  monitoring_service = "none"
}

provider "google" {
  project = local.project_id
  region = local.region
}

provider "google-beta" {
  project = local.project_id
  region = local.region
}

data "google_client_config" "default" {}
