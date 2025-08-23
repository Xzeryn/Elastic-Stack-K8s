######################## Terraform Variables ###################################

##### Provider Settings #####
kube_config_path = "~/.kube/config"
kube_config_context_cluster = "docker-desktop"
kube_config_host = "https://kubernetes.docker.internal:6443"

##### Elastic Registry Settings #####

# registry_namespace = "elastic-registry"

# elastic_package_registry_image = "docker.elastic.co/package-registry/distribution:9.2.1"
# elastic_package_registry_image_pull_policy = "Never"  # Set to Never for Air-Gapped Environments (Pre download the image locally)
elastic_package_registry_ingress_hostname = "epr.k8s.internal"

# elastic_artifact_registry_image = "elastic-artifact-registry"
# elastic_artifact_registry_image_pull_policy = "Never"  # Set to Never for Air-Gapped Environments (Pre download the image locally)
elastic_artifact_registry_ingress_hostname = "ear.k8s.internal"


##### Elastic Settings #####
elastic_cluster_namespace = "elastic" #dashes in namespace cause fleet configurations to fail


##### Elasticsearch Settings #####
elasticsearch_elastic_user_password = "changeme"
# elasticsearch_name = "elasticsearch-sample"
# elasticsearch_image = "docker.elastic.co/elasticsearch/elasticsearch:9.2.1"
elasticsearch_ingress_hostname = "es.k8s.internal"
elasticsearch_node_count = 1 # Default is 3 for production, 1 for development

##### Kibana Settings #####
# kibana_name = "kibana-sample"
# kibana_image = "docker.elastic.co/kibana/kibana:9.2.1"
kibana_ingress_hostname = "kb.k8s.internal"
kibana_node_count = 1 # Default is 2 for production, 1 for development

##### Fleet Server Settings #####
# fleet_server_name = "eck-fleet-server"
# apm_server_name = "eck-apm-server"
# elastic_agent_name = "eck-elastic-agent"
fleet_server_ingress_hostname = "fleet-server.k8s.internal"
apm_server_ingress_hostname = "apm.k8s.internal"
# elastic_agent_image = "docker.elastic.co/beats/elastic-agent:9.2.1"

##### Use Case Settings #####
air_gapped = false

##### K8s Settings #####
k8s_ingress_class_name = "nginx"