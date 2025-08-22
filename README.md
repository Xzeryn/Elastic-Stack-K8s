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
- [Docker](https://docs.docker.com/get-docker/) (for local development)

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
├── registry_images/             # Local registry images
└── README.md                    # This file
```

## ⚙️ Configuration

### Environment Variables

The project uses Terraform variables for configuration. Key variables include:

#### Provider Settings
```hcl
kube_config_path = "~/.kube/config"
kube_config_context_cluster = "docker-desktop"
kube_config_host = "https://kubernetes.docker.internal:6443"
```

#### Elastic Stack Configuration
```hcl
elastic_version = "9.1.2"
eck_version = "3.1.0"
elastic_cluster_namespace = "elastic"
elasticsearch_node_count = 1      # 3 for production
kibana_node_count = 1            # 2 for production
```

#### Security Settings
```hcl
elasticsearch_elastic_user_password = "changeme"  # Change this!
```

#### Ingress Configuration
```hcl
elasticsearch_ingress_hostname = "es.k8s.internal"
kibana_ingress_hostname = "kb.k8s.internal"
fleet_server_ingress_hostname = "fleet-server.k8s.internal"
apm_server_ingress_hostname = "apm.k8s.internal"
```

### Customization

1. **Copy and modify variables**:
   ```bash
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

For environments without internet access:

```hcl
air_gapped = true
elastic_package_registry_image_pull_policy = "Never"
elastic_artifact_registry_image_pull_policy = "Never"
```

### Production Deployment

```hcl
elasticsearch_node_count = 3
kibana_node_count = 2
elasticsearch_elastic_user_password = "your-secure-password"
```

### Custom Storage Classes

```hcl
elasticsearch_storage_class = "fast-ssd"
kibana_storage_class = "fast-ssd"
```

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
elasticsearch_node_count = 5      # Scale Elasticsearch nodes
kibana_node_count = 3            # Scale Kibana instances
```

### Resource Optimization
```hcl
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
