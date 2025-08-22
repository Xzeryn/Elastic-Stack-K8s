resource "kubectl_manifest" "elastic-artifact-registry_deployment" {
  count = var.air_gapped ? 1 : 0
  depends_on = [kubectl_manifest.elastic-package-registry-namespace]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elastic-artifact-registry
  namespace: ${var.registry_namespace}
  labels:
    app: elastic-artifact-registry
    deployment: terraform
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elastic-artifact-registry
  template:
    metadata:
      name: elastic-artifact-registry
      labels:
        app: elastic-artifact-registry
    spec:
      containers:
        - name: ear
          image: ${var.elastic_artifact_registry_image}
          imagePullPolicy: ${var.elastic_artifact_registry_image_pull_policy}
          ports:
            - containerPort: 9080
              name: http
          resources:
            requests:
              cpu: 125m
              memory: 128Mi
            limits:
              cpu: 1000m
              memory: 512Mi
YAML
}

resource "kubectl_manifest" "elastic-artifact-registry_service" {
  count = var.air_gapped ? 1 : 0
  depends_on = [kubectl_manifest.elastic-artifact-registry_deployment]
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  namespace: ${var.registry_namespace}
  labels:
    app: elastic-artifact-registry
    deployment: terraform
  name: elastic-artifact-registry
spec:
  ports:
  - port: 9080
    name: http
    protocol: TCP
    targetPort: 9080
  selector:
    app: elastic-artifact-registry
YAML
}

resource "kubectl_manifest" "elastic-artifact-registry_ingress" {
  count = var.air_gapped ? 1 : 0
  depends_on = [kubectl_manifest.elastic-artifact-registry_service]
  yaml_body = <<YAML
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: elastic-artifact-registry-ingress
  namespace: ${var.registry_namespace}
  labels:
    deployment: terraform
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "http"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: ${var.elastic_artifact_registry_ingress_hostname}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: elastic-artifact-registry
                port:
                  number: 9080
YAML
}