resource "kubectl_manifest" "elastic-package-registry-namespace" {
  count = var.air_gapped ? 1 : 0
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.registry_namespace}
  labels:
    name: ${var.registry_namespace}
    deployment: terraform
YAML
}

resource "kubectl_manifest" "elastic-package-registry_deployment" {
  count = var.air_gapped ? 1 : 0
  depends_on = [kubectl_manifest.elastic-package-registry-namespace[0]]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elastic-package-registry
  namespace: ${var.registry_namespace}
  labels:
    app: elastic-package-registry
    deployment: terraform
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elastic-package-registry
  template:
    metadata:
      name: elastic-package-registry
      labels:
        app: elastic-package-registry
    spec:
      containers:
        - name: epr
          image: ${var.elastic_package_registry_image}
          imagePullPolicy: ${var.elastic_package_registry_image_pull_policy}
          ports:
            - containerPort: 8080
              name: http
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 30
          resources:
            requests:
              cpu: 125m
              memory: 2Gi
            limits:
              cpu: 1000m
              memory: 2Gi
          env:
            - name: EPR_ADDRESS
              value: "0.0.0.0:8080"
YAML
}
resource "kubectl_manifest" "elastic-package-registry_service" {
  count = var.air_gapped ? 1 : 0
  depends_on = [kubectl_manifest.elastic-package-registry_deployment[0]]
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  labels:
    app: elastic-package-registry
    deployment: terraform
  name: elastic-package-registry
  namespace: ${var.registry_namespace}
spec:
  ports:
  - port: 8080
    name: http
    protocol: TCP
    targetPort: http
  selector:
    app: elastic-package-registry
YAML
}

resource "kubectl_manifest" "elastic-package-registry_ingress" {
  count = var.air_gapped ? 1 : 0
  depends_on = [kubectl_manifest.elastic-package-registry_service[0]]
  yaml_body = <<YAML
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: elastic-package-registry-ingress
  namespace: ${var.registry_namespace}
  labels:
    deployment: terraform
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "http"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: ${var.k8s_ingress_class_name}
  rules:
    - host: ${var.elastic_package_registry_ingress_hostname}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: elastic-package-registry
                port:
                  number: 8080
YAML
}