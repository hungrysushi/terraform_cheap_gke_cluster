resource "kubectl_manifest" "argocd-namespace" {
  count = var.enable_argocd ? 1 : 0

  lifecycle {
    ignore_changes = all
  }

  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF
}

resource "helm_release" "argo-cd" {
  count = var.enable_argocd ? 1 : 0

  depends_on = [
    module.gke,
    kubectl_manifest.argocd-namespace,
  ]

  lifecycle {
    ignore_changes = all
  }

  name = "argocd"
  namespace = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = var.argocd_version

  values = [
    var.argocd_values
  ]
}
