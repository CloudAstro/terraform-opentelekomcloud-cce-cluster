## 🌐 Additional Information  

This module provides a flexible way to manage Kubernetes clusters within OpenTelekomCloud's Container Cloud Engine (CCE). It supports features such as node pool configurations, autoscaling, resource limits, and seamless networking integration with the OpenTelekomCloud VPC. It is designed to help deploy Kubernetes clusters for production and development workloads.

## 📚 Resources

- [Terraform OpenTelekomCloud CCE Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cce_cluster_v3)  
- [OpenTelekomCloud CCE Overview](https://docs.otc.t-systems.com/cloud-container-engine/index.html)  
- [Terraform OpenTelekomCloud Provider](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs)  

## ⚠️ Notes  

- Ensure that your VPC and subnet configurations are properly set up before provisioning the Kubernetes cluster.  
- Be mindful of the CCE service limits for node pools and cluster sizes.  
- Tagging your clusters and node pools can help in managing and tracking costs and resources efficiently.  
- Auto-scaling policies should be carefully defined to avoid overscaling or underscaling based on workload patterns.

## 🧾 License  

This module is released under the **Apache 2.0 License**. See the [LICENSE](./LICENSE) file for full details.
