# DO NOT MODIFIY
# Put any changes or customizations in terraform.tfvars

###################### Use Case Variables ######################
variable "air_gapped" {
  description = "Enable air-gapped mode with local registries"
  type        = bool
  default     = false
}

###################### Provider Variables ######################
variable "kube_config_path" {
  description   = "Path to kubeconfig"
  type          = string
  default       = "~/.kube/config"
}

variable "kube_config_context_cluster" {
  description   = "Context of the K8s cluster"
  type          = string
  default       = "docker-desktop"
}

variable "kube_config_host" {
  description   = "URL to K8s cluster"
  type          = string
  default       = "https://kubernetes.docker.internal:6443"
}

###################### Images ######################
variable "eck_operator_image" {
  description   = "Docker image URL for ECK Operator"
  type          = string
  default       = "docker.elastic.co/eck/eck-operator:3.1.0"
}

variable "elasticsearch_image" {
  description   = "Docker image URL for Elasticsearch"
  type          = string
  default       = "docker.elastic.co/elasticsearch/elasticsearch:9.1.2"
}

variable "kibana_image" {
  description   = "Docker image URL for Kibana"
  type          = string
  default       = "docker.elastic.co/kibana/kibana:9.1.2"
}

variable "elastic_agent_image" {
  description   = "Docker image URL for Elastic Agent"
  type          = string
  default       = "docker.elastic.co/beats/elastic-agent:9.1.2"
}

variable "elastic_package_registry_image" {
  description   = "Docker image URL for Elastic Package Registry"
  type          = string
  default       = "docker.elastic.co/package-registry/distribution:9.1.2"
}

###################### Elastic Variables ######################
variable "elastic_version" {
  description   = "Elastic Version"
  type          = string
  default       = "9.1.2"
}

variable "elastic_cluster_namespace" {
  description   = "Namespace for Elastic Stack Components"
  type          = string
  default       = "elastic"  #dashes in namespace cause fleet configurations to fail
}

variable "kubebuilder_version" {
  description   = "Kubebuilder Version"
  type          = string
  default       = "v0.18.0"
}

variable "eck_operator_container_registry" {
  description   = "Setting in the eck operator for container registry"
  type          = string
  default       = "docker.elastic.co"
}

variable "eck_operator_pull_policy" {
  description   = "ECK Operator Docker image download policy"
  type          = string
  default       = "IfNotPresent"
}

###################### Registry Configuration Variables ######################
variable "registry_namespace" {
  description   = "Namespace for Elastic Registries"
  type          = string
  default       = "elastic-registry"
}

variable "elastic_package_registry_image_pull_policy" {
  description   = "EPR Docker image download policy"
  type          = string
  default       = "IfNotPresent"
}

variable "elastic_package_registry_ingress_hostname" {
  description   = "EPR ingress Hostname"
  type          = string
  default       = "epr.localhost"
}

variable "elastic_artifact_registry_image" {
  description   = "Docker image URL for Elastic Artifact Registry"
  type          = string
  default       = "elastic-artifact-registry"
}

variable "elastic_artifact_registry_image_pull_policy" {
  description   = "EAR Docker image download policy"
  type          = string
  default       = "IfNotPresent"
}

variable "elastic_artifact_registry_ingress_hostname" {
  description   = "EAR ingress Hostname"
  type          = string
  default       = "ear.localhost"
}


###################### Elasticsearch Variables ######################
variable "elasticsearch_elastic_user_password" {
  description   = "Default password for user elastic"
  type          = string
  default       = "changeme"
}

variable "elasticsearch_name" {
  description   = "Name of Elasticsearch deployment"
  type          = string
  default       = "eck-elasticsearch"
}

variable "elasticsearch_ingress_hostname" {
  description   = "Elasticsearch ingress Hostname"
  type          = string
  default       = "es.localhost"
}

variable "elasticsearch_node_count" {
  description   = "Number of Elasticsearch Nodes"
  type          = number
  default       = 3
}

variable "elasticsearch_node_store_allow_mmap" {
  description   = "Setting for node.store.allow_mmap"
  type          = bool
  default       = false
}

variable "elasticsearch_storage_class" {
  description   = "Storage class for Elasticsearch persistent volumes (only needed if volumeClaimTemplates are uncommented)"
  type          = string
  default       = "standard"
}

###################### Kibana Variables ######################
variable "kibana_name" {
  description   = "Name of Kibana deployment"
  type          = string
  default       = "eck-kibana"
}

variable "kibana_node_count" {
  description   = "Number of Elasticsearch Nodes"
  type          = number
  default       = 2
}

variable "kibana_ingress_hostname" {
  description   = "Kibana ingress Hostname"
  type          = string
  default       = "kb.localhost"
}

variable "kibana_storage_class" {
  description   = "Storage class for Kibana persistent volumes (only needed if volumeClaimTemplates are uncommented)"
  type          = string
  default       = "standard"
}

###################### Fleet Server Variables ######################
variable "fleet_server_name" {
  description   = "Name of Fleet Server deployment"
  type          = string
  default       = "eck-fleet-server"
}

variable "apm_server_name" {
  description   = "Name of APM Server deployment"
  type          = string
  default       = "eck-apm-server"
}

variable "elastic_agent_name" {
  description   = "Name of Elastic Agent deployment"
  type          = string
  default       = "eck-elastic-agent"
}

variable "fleet_server_ingress_hostname" {
  description   = "Fleet Server ingress Hostname"
  type          = string
  default       = "fleet-server.localhost"
}

variable "apm_server_ingress_hostname" {
  description   = "APM Server ingress Hostname"
  type          = string
  default       = "apm.localhost"
}

###################### K8s Variables ######################
variable "k8s_ingress_class_name" {
  description   = "K8s ingress class name"
  type          = string
  default       = "nginx"
}
