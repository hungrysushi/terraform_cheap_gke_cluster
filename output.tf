output "gke_endpoint" {
  value     = module.gke.endpoint
  sensitive = true
}

output "gke_token" {
  value     = data.google_client_config.default.access_token
  sensitive = true
}

output "gke_certificate" {
  value     = module.gke.ca_certificate
  sensitive = true
}
