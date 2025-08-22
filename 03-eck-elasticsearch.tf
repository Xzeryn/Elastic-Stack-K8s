resource "kubectl_manifest" "elasticsearch_cluster" {
  depends_on = [kubectl_manifest.eck-cluster-namespace]
  yaml_body = <<YAML
# This sample sets up an Elasticsearch cluster with specified number of nodes.
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: ${var.elasticsearch_name}
  namespace: ${var.elastic_cluster_namespace}
  labels:
    deployment: terraform
spec:
  version: ${var.elastic_version}
  image: ${var.elasticsearch_image}
  nodeSets:
  - name: default
    count: ${var.elasticsearch_node_count}
    config:
      node.roles: ["master", "data", "ingest", "remote_cluster_client", "transform", "data_content", "data_hot", "data_warm", "data_cold"]
      node.store.allow_mmap: ${var.elasticsearch_node_store_allow_mmap}
    podTemplate:
      metadata:
        labels:
          deployment: terraform
      spec:
        containers:
        - name: elasticsearch
          resources:
            limits:
              memory: 4Gi
              cpu: 1
          env:
          - name: ES_JAVA_OPTS
            value: "-Xms2g -Xmx2g"
    # volumeClaimTemplates:
    # - metadata:
    #     name: elasticsearch-data # Do not change this name unless you set up a volume mount for the data path.
    #   spec:
    #     accessModes:
    #     - ReadWriteOnce
    #     resources:
    #       requests:
    #         storage: 2Gi
    #     storageClassName: standard
  # # inject secure settings into Elasticsearch nodes from k8s secrets references
  # secureSettings:
  # - secretName: ref-to-secret
  # - secretName: another-ref-to-secret
  #   # expose only a subset of the secret keys (optional)
  #   entries:
  #   - key: value1
  #     path: newkey # project a key to a specific path (optional)
  http:
    # service:
    #   spec:
    #     type: LoadBalancer
    tls:
      selfSignedCertificate:
        subjectAltNames:
        - ip: 127.0.0.1
        - dns: "${var.elasticsearch_ingress_hostname}"
        - dns: "${var.elasticsearch_name}-es-http.${var.elastic_cluster_namespace}.svc"
        - dns: localhost
      # certificate:
      #   # provide your own certificate
      #   secretName: ${var.elasticsearch_name}-es-http-certs-internal
YAML
}

resource "kubectl_manifest" "elasticsearch_ingress" {
  depends_on = [kubectl_manifest.elasticsearch_cluster]
  yaml_body = <<YAML
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: elasticsearch-ingress
  namespace: ${var.elastic_cluster_namespace}
  labels:
    deployment: terraform
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.org/ssl-services: "${var.elasticsearch_name}-es-http"
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "https"

    # nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    # nginx.ingress.kubernetes.io/ssl-redirect: "true"
    # cert-manager.io/issuer: selfsigned
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${var.elasticsearch_ingress_hostname}
    secretName: ${var.elasticsearch_name}-es-http-certs-internal
  rules:
    - host: ${var.elasticsearch_ingress_hostname}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${var.elasticsearch_name}-es-http
                port:
                  number: 9200   
YAML
}