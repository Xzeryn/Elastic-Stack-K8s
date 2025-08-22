data "kubectl_file_documents" "eck-operator" {
    content = file("./yaml_files/operator.yaml")
}

resource "kubectl_manifest" "eck-cluster-operator" {
    depends_on = [ kubectl_manifest.eck-cluster-crds ]
    for_each  = data.kubectl_file_documents.eck-operator.manifests
    yaml_body = each.value
}

resource "kubectl_manifest" "eck-cluster-namespace" {
  depends_on = [kubectl_manifest.eck-cluster-operator]
  yaml_body = <<YAML
# Source: eck-operator/templates/operator-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.elastic_cluster_namespace}
  labels:
    name: ${var.elastic_cluster_namespace}
    deployment: terraform
YAML
}