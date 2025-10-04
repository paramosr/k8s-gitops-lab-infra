terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.31" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.13" }
    kubectl    = { source = "gavinbunney/kubectl",  version = "~> 1.14" }
    null       = { source = "hashicorp/null" }
  }
}

provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "kind-dev"
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand("~/.kube/config")
    config_context = "kind-dev"
  }
}

provider "kubectl" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "kind-dev"
}
