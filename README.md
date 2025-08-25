# Elastic-Stack-K8s

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue.svg)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.20+-326CE5.svg?logo=kubernetes)](https://kubernetes.io/)
[![ECK](https://img.shields.io/badge/ECK-3.1.0-orange.svg)](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)

A comprehensive Terraform-based deployment solution for the complete Elastic Stack on Kubernetes using the Elastic Cloud on Kubernetes (ECK) operator. This project provides infrastructure-as-code for deploying Elasticsearch, Kibana, APM Server, Fleet Server, and Elastic Agent in a Kubernetes environment.

## 🚀 Features

- **Complete Elastic Stack Deployment**: Deploy the entire Elastic Stack including Elasticsearch, Kibana, APM Server, and Fleet Server
- **ECK Operator Integration**: Uses Elastic Cloud on Kubernetes (ECK) operator for native Kubernetes management
- **Infrastructure as Code**: Fully automated deployment using Terraform
- **Flexible Configuration**: Configurable for both development and production environments
- **Air-Gapped Support**: Optional support for air-gapped environments with local registries
- **Multi-Environment Ready**: Easy customization for different deployment scenarios
- **Ingress Integration**: Built-in support for Kubernetes ingress controllers
- **Security Best Practices**: Implements security contexts and RBAC configurations

## 📋 Prerequisites

### Required Software
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) >= 1.20.0
- [Docker](https://docs.docker.com/get-docker/) (for local development and air-gapped deployments)

### Kubernetes Cluster
- Kubernetes cluster version 1.20 or higher
- Cluster with sufficient resources:
  - **Development**: 4 CPU, 8GB RAM minimum
  - **Production**: 8+ CPU, 16GB+ RAM recommended
- Storage class configured for persistent volumes
- Ingress controller (optional, for external access)

### Access Requirements
- `kubectl` access to the target cluster
- Cluster admin permissions for CRD installation
- Ability to create namespaces and RBAC resources
- Internet access for pulling Docker images (unless using air-gapped mode)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   ECK Operator  │  │  Elasticsearch  │  │     Kibana      │  │
│  │   (elastic-     │  │   (elastic)     │  │   (elastic)     │  │
│  │    system)      │  │                 │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  Fleet Server   │  │  APM Server     │  │ Elastic Agent   │  │
│  │   (elastic)     │  │   (elastic)     │  │   (elastic)     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│  ┌─────────────────┐  ┌─────────────────┐                       │
│  │ Package Registry│  │Artifact Registry│                       │
│  │(elastic-registry)│ │(elastic-registry)│                      │
│  └─────────────────┘  └─────────────────┘                       │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
Elastic-Stack-K8s/
├── 01-eck-crds.tf              # Custom Resource Definitions
├── 02-eck-operator.tf          # ECK Operator deployment
├── 03-eck-elasticsearch.tf     # Elasticsearch cluster
├── 04-eck-kibana.tf            # Kibana deployment
├── 05-eck-fleet-server.tf      # Fleet Server for agent management
├── 06-eck-apm-server.tf        # APM Server for application monitoring
├── elastic-package-registry.tf  # Elastic Package Registry
├── elastic-artifact-registry.tf # Elastic Artifact Registry
├── providers.tf                 # Terraform provider configuration
├── variables.tf                 # Variable definitions
├── terraform.tfvars             # Variable values (customize this)
├── yaml_files/                  # Original YAML templates
├── registry_images/             # Docker images and registry components
│   ├── docker_pull_images.sh   # Script to pull all required images
│   ├── elastic_artifact_registry_container/ # Custom artifact registry
│   │   ├── Dockerfile          # Artifact registry container definition
│   │   ├── get-artifacts.sh    # Script to download Elastic artifacts
│   │   ├── nginx-ear.conf      # NGINX configuration for registry
│   │   └── index.html          # Registry landing page
│   └── README.md               # Registry-specific documentation
└── README.md                    # This file
```

## ⚙️ Configuration

### Environment Variables

The project uses Terraform variables for configuration. Key variables include:

#### Provider Settings
```hcl
# In terraform.tfvars
kube_config_path = "~/.kube/config"
kube_config_context_cluster = "docker-desktop"
kube_config_host = "https://kubernetes.docker.internal:6443"
```

#### Elastic Stack Configuration
```hcl
# In terraform.tfvars
elastic_version = "9.1.2"
eck_version = "3.1.0"
elastic_cluster_namespace = "elastic"
elasticsearch_node_count = 1      # 3 for production
kibana_node_count = 1            # 2 for production
```

#### Security Settings
```hcl
# In terraform.tfvars
elasticsearch_elastic_user_password = "changeme"  # Change this!
```

#### Ingress Configuration
```hcl
# In terraform.tfvars
elasticsearch_ingress_hostname = "es.k8s.internal"
kibana_ingress_hostname = "kb.k8s.internal"
fleet_server_ingress_hostname = "fleet-server.k8s.internal"
apm_server_ingress_hostname = "apm.k8s.internal"
```

### Customization

1. **Copy and modify variables**:
   ```bash
   # From project root directory
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your specific values

3. **For production deployments**:
   - Increase node counts
   - Set appropriate resource limits
   - Configure persistent storage
   - Set secure passwords

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/Elastic-Stack-K8s.git
cd Elastic-Stack-K8s
```

### 2. Configure Your Environment
```bash
# From project root directory
# Copy and customize the variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
nano terraform.tfvars
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Plan the Deployment
```bash
terraform plan
```

### 5. Deploy the Stack
```bash
terraform apply
```

### 6. Verify Deployment
```bash
# Check all resources
kubectl get all -n elastic-system
kubectl get all -n elastic

# Check Elasticsearch status
kubectl get elasticsearch -n elastic

# Check Kibana status
kubectl get kibana -n elastic
```

## 🔧 Advanced Configuration

### Air-Gapped Deployment

For environments without internet access, you'll need to pre-pull images and build local registries:

#### Pre-pull Required Images

```bash
# From project root directory
# Navigate to the registry images directory
cd registry_images

# Make the script executable
chmod +x docker_pull_images.sh

# Run the script to pull all required images
./docker_pull_images.sh
```

This script pulls the following images:
- **ECK Operator**: `docker.elastic.co/eck/eck-operator:3.1.0`
- **Elasticsearch**: `docker.elastic.co/elasticsearch/elasticsearch:9.2.1`
- **Kibana**: `docker.elastic.co/kibana/kibana:9.2.1`
- **Elastic Agent**: `docker.elastic.co/beats/elastic-agent:9.2.1`
- **Package Registry**: `docker.elastic.co/package-registry/distribution:9.2.1`

#### Build Elastic Artifact Registry

```bash
# From project root directory
# Navigate to the artifact registry container directory
cd elastic_artifact_registry_container

# Build the artifact registry image
docker build -t elastic-artifact-registry .

# Verify the image was built
docker images | grep elastic-artifact-registry
```

The artifact registry includes:
- Pre-downloaded Elastic packages and artifacts
- NGINX web server for serving artifacts
- Defend artifacts for security features
- Runs on port 9080

#### Configure for Air-Gapped Mode

```hcl
# In terraform.tfvars
air_gapped = true
elastic_package_registry_image_pull_policy = "Never"
elastic_artifact_registry_image_pull_policy = "Never"
```

### Production Deployment

```hcl
# In terraform.tfvars
elasticsearch_node_count = 3
kibana_node_count = 2
elasticsearch_elastic_user_password = "your-secure-password"
```

### Persistent Storage Configuration

**Note**: By default, the Elastic Stack components run without persistent storage. If you need data persistence, you must uncomment the `volumeClaimTemplates` sections in the Terraform files.

#### Custom Storage Classes

Storage class variables are only needed if you uncomment the `volumeClaimTemplates` sections to enable persistent storage:

```hcl
# In terraform.tfvars
# Storage class for Elasticsearch persistent volumes (only needed if volumeClaimTemplates are uncommented)
elasticsearch_storage_class = "fast-ssd"

# Storage class for Kibana persistent volumes (only needed if volumeClaimTemplates are uncommented)
kibana_storage_class = "fast-ssd"
```

#### Enabling Persistent Storage

**To enable persistent storage:**

1. **Uncomment the `volumeClaimTemplates` section in `03-eck-elasticsearch.tf`:**
   ```hcl
   # Change from:
   # volumeClaimTemplates:
   # To:
   volumeClaimTemplates:
   ```

2. **Uncomment the `volumeClaimTemplates` section in `04-eck-kibana.tf`:**
   ```hcl
   # Change from:
   # volumeClaimTemplates:
   # To:
   volumeClaimTemplates:
   ```

3. **Set the appropriate storage class values in `terraform.tfvars`**

4. **Ensure your Kubernetes cluster has the specified storage class available**

**Warning**: Enabling persistent storage will create PersistentVolumeClaims that may persist data beyond the lifecycle of your Terraform deployment. Ensure you have proper backup and cleanup procedures in place.

## 📊 Monitoring and Management

### Access Kibana
```bash
# Port forward to access Kibana
kubectl port-forward -n elastic svc/kibana-sample-kb-http 5601:5601
```

### Check Elasticsearch Health
```bash
# Get cluster health
kubectl get elasticsearch -n elastic -o jsonpath='{.items[0].status.health}'

# Check cluster status
kubectl get elasticsearch -n elastic -o yaml
```

### View Logs
```bash
# ECK Operator logs
kubectl logs -n elastic-system -l control-plane=elastic-operator

# Elasticsearch logs
kubectl logs -n elastic -l common.k8s.elastic.co/type=elasticsearch
```

## 🛠️ Troubleshooting

### Common Issues

#### StatefulSet Stuck Creating
```bash
# Check events
kubectl get events -n elastic-system --sort-by='.lastTimestamp'

# Check pod status
kubectl get pods -n elastic-system -o wide

# Check resource quotas
kubectl describe resourcequota -n elastic-system
```

#### Image Pull Errors
```bash
# Check image pull policy
kubectl get pods -n elastic-system -o yaml | grep imagePullPolicy

# Verify image exists
docker pull docker.elastic.co/eck/eck-operator:3.1.0
```

#### Storage Issues
```bash
# Check storage classes
kubectl get storageclass

# Check persistent volume claims
kubectl get pvc -n elastic
```

#### Image Pull Issues (Air-Gapped Environments)
```bash
# Check if images exist locally
docker images | grep elastic

# Verify image pull policies
kubectl get pods -n elastic-system -o yaml | grep imagePullPolicy

# Check for image pull errors in pod events
kubectl describe pod <pod-name> -n elastic-system | grep -A 5 -B 5 "Failed"

# Test image pull manually
docker pull docker.elastic.co/eck/eck-operator:3.1.0

# Check Docker daemon logs
sudo journalctl -u docker.service -f
```

### Debug Commands

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Check kubectl manifest status
kubectl get all -A -o yaml | grep -A 10 -B 10 "elastic"

# Verify CRDs are installed
kubectl get crd | grep elastic
```

## 🔒 Security Considerations

### Default Security
- **RBAC**: Proper role-based access control implemented
- **Security Contexts**: Non-root containers with dropped capabilities
- **Network Policies**: Isolated network access (configure as needed)
- **Secrets Management**: Kubernetes secrets for sensitive data

### Security Hardening
1. **Change default passwords** in `terraform.tfvars`
2. **Enable TLS** for all communications
3. **Configure network policies** for pod-to-pod communication
4. **Use secrets management** for production deployments
5. **Enable audit logging** on the Kubernetes cluster

## 📈 Scaling and Performance

### Horizontal Scaling
```hcl
# In terraform.tfvars
elasticsearch_node_count = 5      # Scale Elasticsearch nodes
kibana_node_count = 3            # Scale Kibana instances
```

### Resource Optimization
```hcl
# In terraform.tfvars
elasticsearch_resources = {
  requests = {
    cpu    = "2"
    memory = "4Gi"
  }
  limits = {
    cpu    = "4"
    memory = "8Gi"
  }
}
```

### Storage Scaling
- Configure appropriate storage classes
- Use SSD storage for production workloads
- Implement backup and disaster recovery

## 🧹 Cleanup

### Remove the Stack
```bash
terraform destroy
```

### Manual Cleanup (if needed)
```bash
# Run these commands if terraform destroy fails
# Remove namespaces
kubectl delete namespace elastic
kubectl delete namespace elastic-system
kubectl delete namespace elastic-registry

# Remove CRDs
kubectl delete crd elasticsearches.elasticsearch.k8s.elastic.co
kubectl delete crd kibanas.kibana.k8s.elastic.co
# ... remove other CRDs as needed
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Terraform best practices
- Add proper documentation for new features
- Include tests where applicable
- Update this README for significant changes

## 📚 Additional Resources

- [ECK Documentation](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)
- [Elasticsearch Documentation](https://www.elastic.co/guide/index.html)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This project is provided as-is for educational and development purposes. For production use, ensure proper testing, security review, and compliance with your organization's policies.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/Elastic-Stack-K8s/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/Elastic-Stack-K8s/discussions)
- **Wiki**: [Project Wiki](https://github.com/yourusername/Elastic-Stack-K8s/wiki)

---

**Happy Elastic Stacking! 🚀**
