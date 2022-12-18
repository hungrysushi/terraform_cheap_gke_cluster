resource "google_compute_network" "vpc" {
  count = var.create_networking ? 1 : 0

  name                    = var.vpc
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count = var.create_networking ? 1 : 0

  name          = var.subnet
  region        = var.region
  network       = google_compute_network.vpc[0].name
  ip_cidr_range = "10.142.0.0/20"

  secondary_ip_range {
    range_name    = local.ip_range_pods
    ip_cidr_range = "10.88.0.0/14"
  }

  secondary_ip_range {
    range_name    = local.ip_range_services
    ip_cidr_range = "10.92.0.0/20"
  }
}
