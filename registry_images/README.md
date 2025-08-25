# Registry Images

This directory contains scripts and configurations for managing Docker images required by the Elastic-Stack-K8s project, including pre-pulling images and building a custom Elastic Artifact Registry.

## 📋 Overview

The registry images directory provides two main functionalities:

1. **Pre-pulling Docker Images**: Script to download all required Elastic Stack images locally
2. **Custom Artifact Registry**: Containerized registry for air-gapped environments

## 🐳 Pre-pulling Docker Images

### Purpose

The `docker_pull_images.sh` script downloads all required Docker images to your local Docker registry. This is useful for:
- **Air-gapped deployments** where internet access is limited
- **Ensuring image availability** before deployment
- **Offline environments** where images need to be transferred separately
- **Testing and development** without relying on external registries

### Usage

#### 1. Make the Script Executable

```bash
# From the project root directory
cd registry_images
chmod +x docker_pull_images.sh
```

#### 2. Run the Script

```bash
# Pull all required images
./docker_pull_images.sh
```

#### 3. Verify Images

```bash
# Check that all images were downloaded
docker images | grep elastic
```

### What Gets Downloaded

The script pulls the following images with their specific versions:

| Component | Image | Version | Purpose |
|-----------|-------|---------|---------|
| **ECK Operator** | `docker.elastic.co/eck/eck-operator` | `3.1.0` | Kubernetes operator for Elastic Stack |
| **Elasticsearch** | `docker.elastic.co/elasticsearch/elasticsearch` | `9.2.1` | Search and analytics engine |
| **Kibana** | `docker.elastic.co/kibana/kibana` | `9.2.1` | Data visualization and management UI |
| **Elastic Agent** | `docker.elastic.co/beats/elastic-agent` | `9.2.1` | Unified agent for data collection |
| **Package Registry** | `docker.elastic.co/package-registry/distribution` | `9.2.1` | Elastic package distribution |

### Customizing Versions

To use different versions, edit the script variables:

```bash
# Edit the script to change versions
nano docker_pull_images.sh

# Update these variables:
ELASTIC_VERSION=9.2.1
ECK_VERSION=3.1.0
```

### Manual Image Pulling

If you prefer to pull images individually:

```bash
# ECK Operator
docker pull docker.elastic.co/eck/eck-operator:3.1.0

# Elasticsearch
docker pull docker.elastic.co/elasticsearch/elasticsearch:9.2.1

# Kibana
docker pull docker.elastic.co/kibana/kibana:9.2.1

# Elastic Agent
docker pull docker.elastic.co/beats/elastic-agent:9.2.1

# Package Registry
docker pull docker.elastic.co/package-registry/distribution:9.2.1
```

## 🏗️ Building Elastic Artifact Registry

### Purpose

The Elastic Artifact Registry (EAR) is a custom container that provides:
- **Pre-downloaded Elastic packages** and artifacts
- **Local package repository** for air-gapped environments
- **NGINX web server** for serving artifacts
- **Defend artifacts** for security features

### Prerequisites

- Docker installed and running
- Internet access (for initial build)
- Sufficient disk space (~2-5GB depending on packages)

### Building the Registry

#### 1. Navigate to the Container Directory

```bash
# From the project root directory
cd registry_images/elastic_artifact_registry_container
```

#### 2. Build the Image

```bash
# Build with default Elastic version (9.2.1)
docker build -t elastic-artifact-registry .

# Or specify a custom version
docker build --build-arg ELASTIC_VERSION=9.2.1 -t elastic-artifact-registry:9.2.1 .
```

#### 3. Verify the Build

```bash
# Check that the image was created
docker images | grep elastic-artifact-registry

# Expected output:
# elastic-artifact-registry    latest    <image-id>    <created>    <size>
```

### Registry Contents

The built registry contains:

- **Elastic Packages**: Pre-downloaded system, kubernetes, apm, and other packages
- **Defend Artifacts**: Security-related packages and configurations
- **NGINX Configuration**: Web server setup for serving artifacts
- **Package Index**: HTML interface for browsing available packages

### Testing the Registry

#### 1. Run the Registry

```bash
# Run in detached mode
docker run -d -p 9080:9080 --name ear-test elastic-artifact-registry

# Or with a specific version tag
docker run -d -p 9080:9080 --name ear-test elastic-artifact-registry:9.2.1
```

#### 2. Verify Access

```bash
# Test HTTP access
curl http://localhost:9080/

# Check package availability
curl http://localhost:9080/downloads/
```

#### 3. Stop and Cleanup

```bash
# Stop the container
docker stop ear-test

# Remove the container
docker rm ear-test
```

### Registry Configuration

The registry runs on **port 9080** by default and includes:

- **NGINX web server** for serving artifacts
- **Package downloads** in `/opt/elastic-packages/downloads`
- **Index page** at the root URL
- **Package metadata** for integration with Fleet

## 🔧 Advanced Usage

### Saving Images for Transfer

For environments where you need to transfer images:

```bash
# Save images as tar files
docker save docker.elastic.co/eck/eck-operator:3.1.0 -o eck-operator-3.1.0.tar
docker save docker.elastic.co/elasticsearch/elasticsearch:9.2.1 -o elasticsearch-9.2.1.tar
docker save docker.elastic.co/kibana/kibana:9.2.1 -o kibana-9.2.1.tar
docker save docker.elastic.co/beats/elastic-agent:9.2.1 -o elastic-agent-9.2.1.tar
docker save docker.elastic.co/package-registry/distribution:9.2.1 -o package-registry-9.2.1.tar

# Transfer tar files to target system
# Then load images:
docker load -i eck-operator-3.1.0.tar
docker load -i elasticsearch-9.2.1.tar
docker load -i kibana-9.2.1.tar
docker load -i elastic-agent-9.2.1.tar
docker load -i package-registry-9.2.1.tar
```

### Customizing the Artifact Registry

#### 1. Modify Package Downloads

Edit `get-artifacts.sh` to change which packages are downloaded:

```bash
# Add or remove packages as needed
nano get-artifacts.sh
```

#### 2. Custom NGINX Configuration

Modify `nginx-ear.conf` for custom web server settings:

```bash
# Customize NGINX behavior
nano nginx-ear.conf
```

#### 3. Add Custom Artifacts

Place additional artifacts in the `downloads` directory before building:

```bash
# Add custom packages or configurations
cp my-custom-package.zip downloads/
```

## 🚨 Troubleshooting

### Common Issues

#### Image Pull Failures

```bash
# Check Docker daemon status
sudo systemctl status docker

# Verify internet connectivity
ping docker.elastic.co

# Check Docker logs
sudo journalctl -u docker.service -f
```

#### Build Failures

```bash
# Check Docker build context
docker build --no-cache -t elastic-artifact-registry .

# Verify Dockerfile syntax
docker build --dry-run .

# Check available disk space
df -h
```

#### Registry Access Issues

```bash
# Verify container is running
docker ps | grep elastic-artifact-registry

# Check container logs
docker logs ear-test

# Verify port binding
netstat -tlnp | grep 9080
```

### Debug Commands

```bash
# Inspect image layers
docker history elastic-artifact-registry

# Check image contents
docker run --rm -it elastic-artifact-registry ls -la /opt/elastic-packages/

# Test internal connectivity
docker exec -it ear-test curl localhost:9080/
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Elastic Package Registry](https://github.com/elastic/package-registry)
- [NGINX Configuration](https://nginx.org/en/docs/)
- [Elastic Artifacts](https://artifacts.elastic.co/)

## 🤝 Contributing

To improve the registry images:

1. Test changes in a development environment
2. Update version numbers in scripts when needed
3. Verify that all images can be pulled successfully
4. Test the artifact registry build and functionality
5. Update this README for any new features or changes

---

**Note**: These images and the artifact registry are primarily intended for air-gapped or offline deployments. For standard deployments with internet access, Terraform will pull images directly from Docker Hub.