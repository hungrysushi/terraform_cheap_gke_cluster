resource "google_compute_address" "ingress" {
  provider = google-beta

  name = var.compute_address_name

  labels = {
    kubeip = var.name
  }
}

resource "google_service_account" "kubeip_service_account" {
  account_id   = "kubeip-${var.name}"
  display_name = "kubeIP"
}

resource "google_service_account_key" "kubeip-key" {
  service_account_id = google_service_account.kubeip_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_custom_role" "kubeip" {
  role_id     = "kubeip_${replace(var.name, "-", "_")}"
  title       = local.roles["title"]
  description = local.roles["description"]
  stage       = local.roles["stage"]
  permissions = local.roles["includedPermissions"]
}

resource "google_service_account_iam_binding" "kubeip" {
  service_account_id = google_service_account.kubeip_service_account.name
  role               = google_project_iam_custom_role.kubeip.id
  members = [
    "serviceAccount:${google_service_account.kubeip_service_account.email}"
  ]
}

resource "google_project_iam_binding" "kubeip" {
  project = var.project_id
  role    = google_project_iam_custom_role.kubeip.id

  members = [
    "serviceAccount:${google_service_account.kubeip_service_account.email}"
  ]
}

resource "kubectl_manifest" "kubeip-configmap" {
  # lifecycle {
  #   ignore_changes = all
  # }

  depends_on = [
    module.gke
  ]

  yaml_body = local.kubeip_configmap
}

resource "kubectl_manifest" "kubeip-deployment" {
  # lifecycle {
  #   ignore_changes = all
  # }

  depends_on = [
    module.gke,
    kubectl_manifest.kubeip-key
  ]

  for_each = local.kubeip_deployment_yamls

  yaml_body = each.value
}

resource "kubectl_manifest" "kubeip-key" {
  depends_on = [
    module.gke
  ]

  yaml_body = <<EOT
apiVersion: v1
kind: Secret
metadata:
  name: kubeip-key
  namespace: kube-system
type: Opaque
data:
  key.json: ${google_service_account_key.kubeip-key.private_key}
EOT
}

locals {
  kubeip_configmap = templatefile("${path.module}/kubeip/deploy/kubeip-configmap.yaml", {
    label_value = var.name,
    node_pool   = var.ingress_pool.config.name
  })

  kubeip_deployment_pool = var.kubeip_node_selector == "" ? var.additional_pools[0].name : var.kubeip_node_selector
  kubeip_deployment_raw = templatefile("${path.module}/kubeip/deploy/kubeip-deployment.yaml", {
    node_pool = local.kubeip_deployment_pool
  })
  kubeip_deployment_yamls = {
    for yaml in split("---", local.kubeip_deployment_raw) :
    yamldecode(yaml)["kind"] => yaml
  }

  roles = yamldecode(file("${path.module}/kubeip/roles.yaml"))
}
