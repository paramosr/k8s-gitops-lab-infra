# 1- Cluster kind (create/delete with Terraform)
resource "null_resource" "kind_cluster" {
  triggers = { name = "dev" } # change value if you want to force recreate

  provisioner "local-exec" {
    command = <<EOT
      if ! kind get clusters | grep -q "^dev$"; then
        cat > kind-cluster.yaml <<'YML'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: dev
nodes:
- role: control-plane
- role: worker
YML
        kind create cluster --config kind-cluster.yaml
      fi
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name dev || true"
  }
}

# 2- Namespace Argo CD + install Argo CD via Helm
resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
  depends_on = [null_resource.kind_cluster]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "6.7.12"

  values = [yamlencode({
    server = { service = { type = "NodePort" } }
  })]

  depends_on = [kubernetes_namespace.argocd]
}

# 3- Namespaces by environment
resource "kubernetes_namespace" "envs" {
  for_each = toset(["dev", "staging", "prod"])
  metadata { name = each.key }
  depends_on = [helm_release.argocd]
}

# 4- Argo Applications (dev/staging/prod) – pointing to repo gitops paths
resource "kubectl_manifest" "app_hello_dev" {
  yaml_body = file("${path.module}/files/app-hello-dev.yaml")
  depends_on = [kubernetes_namespace.envs]
}

resource "kubectl_manifest" "app_hello_staging" {
  yaml_body = file("${path.module}/files/app-hello-staging.yaml")
  depends_on = [kubernetes_namespace.envs]
}

resource "kubectl_manifest" "app_hello_prod" {
  yaml_body = file("${path.module}/files/app-hello-prod.yaml")
  depends_on = [kubernetes_namespace.envs]
}
