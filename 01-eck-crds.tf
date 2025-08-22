data "kubectl_file_documents" "eck-crds" {
    content = file("./yaml_files/crds.yaml")
}

resource "kubectl_manifest" "eck-cluster-crds" {
    for_each  = data.kubectl_file_documents.eck-crds.manifests
    yaml_body = each.value
}