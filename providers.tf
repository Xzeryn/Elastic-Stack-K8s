terraform {
  required_providers {
    kubernetes = {
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      source = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      # https://registry.terraform.io/providers/hashicorp/helm/latest
      source = "hashicorp/helm"
      version = "3.0.2"
    }
    kubectl = {
      # https://registry.terraform.io/providers/alekc/kubectl/latest
      # Provides `yaml_body` for kubectl_manifest resource
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
  }
}

provider "kubernetes" {
  # Configuration options
  host = var.kube_config_host
  config_context_cluster = var.kube_config_context_cluster
  config_path = var.kube_config_path
}
provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}
provider "kubectl" {
  config_path = var.kube_config_path
  config_context_cluster = var.kube_config_context_cluster
  host = var.kube_config_host
  apply_retry_count = 5
  insecure = true
}