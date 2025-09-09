# OpenTelekomCloud CCE (Kubernetes) Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/CloudAstro/cce/opentelekomcloud/)

This module is designed to manage and deploy Kubernetes clusters within OpenTelekomCloud's Container Cloud Engine (CCE) service. It allows flexible configuration options for cluster creation, node pool management, networking, and custom resource limits.

# Features

- **Kubernetes Cluster Management**: Automates the creation and management of Kubernetes clusters within OpenTelekomCloud CCE.
- **Node Pool Management**: Easily configure node pools with custom VM types, auto-scaling, and resource allocations.
- **Networking Integration**: Supports seamless integration with OpenTelekomCloud VPC and security groups for network security.
- **Resource Limits**: Allows for setting resource limits on nodes and pods for optimized cluster performance.
- **Flexible Autoscaling**: Configure cluster auto-scaling based on resource utilization to ensure high availability and efficient resource use.

# Setup Requirements

To successfully apply the module, make sure to source the required variables either through the `.envrc` file or use `direnv` to automatically load environment variables for configuration. This step is crucial for proper execution of the module.

You can also use AK/SK authentication (`OS_ACCESS_KEY` and `OS_SECRET_KEY`) as an alternative to `OS_PASSWORD` and `OS_USERNAME` for accessing OpenTelekomCloud.

Ensure the following variables are set up correctly in your `.envrc` file for authentication:

```shell
export OS_USERNAME="USERNAME"
export OS_PASSWORD="PASSWORD"
export OS_DOMAIN_NAME="OTC000xxxx"
export OS_PROJECT_NAME="eu-de_project-name"
export OS_REGION="eu-de"
```

Once the .envrc file is set up, you can source it in your shell by running the following command:

```shell
source .envrc
```

# Example Usage

This example demonstrates how to provision a Kubernetes cluster with a configurable node pool and autoscaling enabled
