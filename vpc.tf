resource "google_compute_network" "vpc" {
  count = var.create_networking ? 1 : 0

  name = var.vpc
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count = var.create_networking ? 1 : 0

  name = var.subnet
  region = var.region
  network = google_compute_network.vpc[0].name
  ip_cidr_range = "10.10.0.0/24"

  secondary_ip_range {
    range_name = local.ip_range_pods
    ip_cidr_range = "10.20.0.0/24"
  }

  secondary_ip_range {
    range_name = local.ip_range_services
    ip_cidr_range = "10.30.0.0/24"
  }
}
