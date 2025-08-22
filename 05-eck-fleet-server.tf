resource "kubectl_manifest" "fleet_server_agent" {
  depends_on = [kubectl_manifest.kibana]
  yaml_body = <<YAML
apiVersion: agent.k8s.elastic.co/v1alpha1
kind: Agent
metadata:
  name: ${var.fleet_server_name}
  namespace: ${var.elastic_cluster_namespace}
  labels:
    deployment: terraform
spec:
  version: ${var.elastic_version}
  kibanaRef:
    name: ${var.kibana_name}
  elasticsearchRefs:
  - name: ${var.elasticsearch_name}
  mode: fleet
  fleetServerEnabled: true
  policyID: eck-fleet-server
  deployment:
    replicas: 1
    podTemplate:
      metadata:
        labels:
          deployment: terraform
      spec:
        serviceAccountName: fleet-server
        automountServiceAccountToken: true
        securityContext:
          runAsUser: 0 
  http:
    tls:
      selfSignedCertificate:
        subjectAltNames:
        - ip: 127.0.0.1
        - dns: "${var.fleet_server_ingress_hostname}"
        - dns: "${var.fleet_server_name}-agent-http.${var.elastic_cluster_namespace}.svc"
        - dns: localhost
YAML
}

resource "kubectl_manifest" "fleet_server_cluster_role" {
  depends_on = [kubectl_manifest.fleet_server_agent]
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fleet-server
  labels:
    deployment: terraform
rules:
- apiGroups: [""]
  resources:
  - pods
  - namespaces
  - nodes
  verbs:
  - get
  - watch
  - list
- apiGroups: ["apps"]
  resources:
    - replicasets
  verbs:
    - get
    - watch
    - list
- apiGroups: ["batch"]
  resources:
    - jobs
  verbs:
    - get
    - watch
    - list
- apiGroups: ["coordination.k8s.io"]
  resources:
  - leases
  verbs:
  - get
  - create
  - update
YAML
}

resource "kubectl_manifest" "fleet_server_serviceAccount" {
  depends_on = [kubectl_manifest.fleet_server_cluster_role]
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fleet-server
  namespace: ${var.elastic_cluster_namespace}
  labels:
    deployment: terraform
YAML
}

resource "kubectl_manifest" "fleet_server_clusterRoleBinding" {
  depends_on = [kubectl_manifest.fleet_server_serviceAccount]
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fleet-server
subjects:
- kind: ServiceAccount
  name: fleet-server
  namespace: ${var.elastic_cluster_namespace}
roleRef:
  kind: ClusterRole
  name: fleet-server
  apiGroup: rbac.authorization.k8s.io
YAML
}

resource "kubectl_manifest" "elastic_fleet_server_ingress" {
  depends_on = [kubectl_manifest.fleet_server_clusterRoleBinding]
  yaml_body = <<YAML
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: elastic-fleet-server-ingress
  namespace: ${var.elastic_cluster_namespace}
  labels:
    deployment: terraform
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.org/ssl-services: "${var.fleet_server_name}-agent-http"
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "https"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${var.fleet_server_ingress_hostname} 
    secretName: ${var.fleet_server_name}-agent-http-certs-internal  
  rules:
    - host: ${var.fleet_server_ingress_hostname}
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: ${var.fleet_server_name}-agent-http
              port:
                number: 8220
YAML
}