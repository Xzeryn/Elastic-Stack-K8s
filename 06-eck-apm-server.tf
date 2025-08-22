resource "kubectl_manifest" "elastic_apm_server_service" {
  depends_on = [kubectl_manifest.elastic_fleet_server_ingress]
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: ${var.apm_server_name}
  namespace: ${var.elastic_cluster_namespace}
  labels:
    deployment: terraform
spec:
  selector:
    agent.k8s.elastic.co/name: ${var.fleet_server_name}
  ports:
  - protocol: TCP
    port: 8200
YAML
}

resource "kubectl_manifest" "elastic_apm_server_ingress" {
  depends_on = [kubectl_manifest.elastic_apm_server_service]
  yaml_body = <<YAML
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: elastic-apm-server-ingress
  namespace: ${var.elastic_cluster_namespace}
  labels:
    deployment: terraform
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.org/ssl-services: "${var.fleet_server_name}-agent-http"
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "http"
spec:
  ingressClassName: nginx
  rules:
    - host: ${var.apm_server_ingress_hostname}
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: ${var.apm_server_name}
              port:
                number: 8200
YAML
}