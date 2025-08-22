#! /bin/bash

ELASTIC_VERSION=9.2.1
ECK_VERSION=3.1.0

# Package Registry
docker pull docker.elastic.co/package-registry/distribution:${ELASTIC_VERSION}

# Artifact Registry is built using docker build command, see sub directory.

# ECK Operator
docker pull docker.elastic.co/eck/eck-operator:${ECK_VERSION}

# Elasticsearch
docker pull docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}

# Kibana
docker pull docker.elastic.co/kibana/kibana:${ELASTIC_VERSION}

# Elastic Agent
docker pull docker.elastic.co/beats/elastic-agent:${ELASTIC_VERSION}
