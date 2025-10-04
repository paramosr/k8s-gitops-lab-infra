output "argocd_admin_password" {
  value     = try(data.kubernetes_secret.argocd_admin.data.password, null)
  sensitive = true
}

data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}
