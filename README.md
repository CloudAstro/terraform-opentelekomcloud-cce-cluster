<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
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

```hcl
module "vpc" {
  source      = "CloudAstro/vpc/opentelekomcloud"
  version     = "1.0.0"
  name        = "vpc"
  description = "description"
  cidr        = "192.168.10.0/24"
}

module "snet" {
  source      = "CloudAstro/vpc-subnet/opentelekomcloud"
  name        = "snet"
  description = "description"
  cidr        = "192.168.10.0/26"
  gateway_ip  = "192.168.10.1"
  vpc_id      = module.vpc.vpc_v1.id
}

resource "opentelekomcloud_compute_secgroup_v2" "secgroup_1" {
  name        = "my_secgroup"
  description = "my security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

module "eip" {
  source = "CloudAstro/vpc-eip/opentelekomcloud"
  publicip = {
    type = "5_bgp"
    name = "cce-test-eip"
  }
  bandwidth = {
    name        = "cce-test-eip"
    size        = 1000
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "opentelekomcloud_compute_keypair_v2" "create-keypair" {
  name = "new-keypair"
}

module "cce" {
  source = "../../"
  name   = "cce-cluster"
  labels = {
    foo = "bar"
  }
  annotations = {
    foo = "bar"
  }
  timezone                 = "Europe/Madrid"
  flavor_id                = "cce.s2.small"
  cluster_version          = "v1.30"
  cluster_type             = "VirtualMachine"
  description              = "cce cluster"
  enable_volume_encryption = true
  vpc_id                   = module.vpc.vpc_v1.id
  subnet_id                = module.snet.vpc_subnet.network_id
  security_group_id        = opentelekomcloud_compute_secgroup_v2.secgroup_1.id
  container_network_type   = "overlay_l2"
  container_network_cidr   = "172.16.0.0/16"
  api_access_trustlist     = ["0.0.0.0/0"]
  authentication_mode      = "authenticating_proxy"
  authenticating_proxy = [{
    ca          = base64encode(tls_self_signed_cert.ca.cert_pem)
    cert        = base64encode(tls_locally_signed_cert.server.cert_pem)
    private_key = base64encode(tls_private_key.server.private_key_pem)
  }]
  masters = [
    {
      availability_zone = "eu-de-01"
    },
    {
      availability_zone = "eu-de-02"
    },
    {
      availability_zone = "eu-de-02"
    },
  ]
  eip                     = module.eip.vpc_eip.publicip[0].ip_address
  kubernetes_svc_ip_range = "10.247.0.0/16"
  kube_proxy_mode         = "ipvs"
  delete_all_storage      = false
  delete_all_network      = false
  node_pools = {
    node_pool_1 = {
      flavor             = "s3.large.2"
      key_pair           = opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "HCE OS 2.0"
      name               = "node-pool-1"
      availability_zone  = "eu-de-01"
      initial_node_count = 1
      max_node_count     = 2
      root_volume = {
        size       = 40
        volumetype = "SSD"
      }
      data_volumes = [{
        size       = 100
        volumetype = "SSD"
      }]
    }
    node_pool_2 = {
      flavor             = "s3.large.2"
      key_pair           = opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "HCE OS 2.0"
      name               = "node-pool-2"
      availability_zone  = "eu-de-02"
      initial_node_count = 1
      max_node_count     = 2
      root_volume = {
        size       = 40
        volumetype = "SSD"
      }
      data_volumes = [{
        size       = 100
        volumetype = "SSD"
      }]
    }
    node_pool_3 = {
      flavor             = "s3.large.2"
      key_pair           = resource.opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "HCE OS 2.0"
      name               = "node-pool-3"
      availability_zone  = "eu-de-03"
      initial_node_count = 1
      max_node_count     = 2
      root_volume = {
        size       = 40
        volumetype = "SSD"
      }
      data_volumes = [{
        size       = 100
        volumetype = "SSD"
      }]
    }
  }
}
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.0 |
| <a name="requirement_opentelekomcloud"></a> [opentelekomcloud](#requirement\_opentelekomcloud) | >= 1.36.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opentelekomcloud"></a> [opentelekomcloud](#provider\_opentelekomcloud) | >= 1.36.35 |

## Resources

| Name | Type |
|------|------|
| [opentelekomcloud_cce_addon_v3.this](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cce_addon_v3) | resource |
| [opentelekomcloud_cce_cluster_v3.cluster](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cce_cluster_v3) | resource |
| [opentelekomcloud_cce_node_pool_v3.this](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cce_node_pool_v3) | resource |
| [opentelekomcloud_cce_node_v3.this](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cce_node_v3) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | * `cluster_type` - (Required) Cluster Type, possible values are VirtualMachine and BareMetal. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>cluster_type = "VirtualMachine"</pre> | `string` | n/a | yes |
| <a name="input_container_network_type"></a> [container\_network\_type](#input\_container\_network\_type) | * `container_network_type` - (Required) Container network type.<br/>  overlay\_l2 - An overlay\_l2 network built for containers by using Open vSwitch(OVS).<br/>  vpc-router - A vpc-router network built for containers by using ipvlan and custom VPC routes.<br/>  eni - Cloud native 2.0 network model which integrates the native ENI capability of VPC.<br/>  underlay\_ipvlan - An underlay\_ipvlan network built for bare metal servers by using ipvlan.<br/><br/>Example input:<pre>container_network_type = "overlay_l2"</pre> | `string` | n/a | yes |
| <a name="input_flavor_id"></a> [flavor\_id](#input\_flavor\_id) | * `flavor_id` - (Required) Cluster specifications. Changing this parameter will create a new cluster resource.<br/>   cce.s1.small - small-scale single cluster (up to 50 nodes).<br/>   cce.s1.medium - medium-scale single cluster (up to 200 nodes).<br/>   cce.s2.small - small-scale HA cluster (up to 50 nodes).<br/>   cce.s2.medium - medium-scale HA cluster (up to 200 nodes).<br/>   cce.s2.large - large-scale HA cluster (up to 1000 nodes).<br/>   cce.s2.xlarge - ultra-large-scale, high availability cluster (<= 2,000 nodes).<br/><br/>Example input:<pre>flavor_id = "cce.s1.small"</pre> | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | * `name` - (Required) Cluster name. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>name = "cce-cluster"</pre> | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | * `subnet_id` - (Required) The Network ID of the subnet used to create the node. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>subnet_id = opentelekomcloud_vpc_subnet_v1.example.subnet_id</pre> | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | * `vpc_id` - - (Required) The ID of the VPC used to create the node. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>vpc_id = opentelekomcloud_vpc_v1.example.id</pre> | `string` | n/a | yes |
| <a name="input_addons"></a> [addons](#input\_addons) | The following arguments are supported:<br/>* `template_name` - (Required, String, ForceNew) Name of the add-on template to be installed, for example, `coredns`.<br/>* `template_version` - (Required, String, ForceNew) Version number of the add-on to be installed or upgraded, for example, `v1.0.0`.<br/>* `cluster_id` - (Required, String, ForceNew) ID of cluster to install the add-on on.<br/>* `values` - (Required, List) Parameters of the template to be installed or upgraded.<br/>    * `basic` - (Required, Map) Basic add-on information.<br/>    * `custom` - (Required, Map) Custom parameters of the add-on.<br/>    * `flavor` - (Optional, String) Specifies the json string vary depending on the add-on.<br/><br/>Example input:<pre>addons = {<br/>  autoscaling = {<br/>    template_name    = "autoscaler"<br/>    template_version = "1.30.18"<br/>    values = {<br/>        basic = {<br/>          cceEndpoint = "https://cce.eu-de.otc.t-systems.com"<br/>          ecsEndpoint = "https://ecs.eu-de.otc.t-systems.com"<br/>          region      = "eu-de"<br/>          swr_add     = "100.125.7.25:20202",<br/>          swr_usr     = "cce-addons"<br/>        }<br/>        custom = {<br/>          coresTotal                     = 32000<br/>          expander                       = "priority"<br/>          logLevel                       = 4<br/>          maxEmptyBulkDeleteFlag         = 10<br/>          maxNodeProvisionTime           = 15<br/>          maxNodesTotal                  = 1000<br/>          memoryTotal                    = 128000<br/>          scaleDownDelayAfterAdd         = 10<br/>          scaleDownDelayAfterDelete      = 11<br/>          scaleDownDelayAfterFailure     = 3<br/>          scaleDownEnabled               = true<br/>          scaleDownUnneededTime          = 10<br/>          scaleDownUtilizationThreshold  = 0.5<br/>          scaleUpCpuUtilizationThreshold = 1<br/>          scaleUpMemUtilizationThreshold = 1<br/>          scaleUpUnscheduledPodEnabled   = true<br/>          scaleUpUtilizationEnabled      = true<br/>          tenant_id                      = ""<br/>          unremovableNodeRecheckTimeout  = 5<br/>        }<br/>    }<br/>  }<br/>}</pre> | <pre>map(object({<br/>    template_name    = string<br/>    template_version = optional(string)<br/>    cluster_id       = optional(string)<br/>    values = object({<br/>      basic  = map(any)<br/>      custom = map(any)<br/>      flavor = optional(string)<br/>    })<br/>  }))</pre> | `null` | no |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | * `annotations` - (Optional) Cluster annotation, key/value pair format. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>annotations = {<br/>  foo = "bar"<br/>}</pre> | `map(string)` | `{}` | no |
| <a name="input_api_access_trustlist"></a> [api\_access\_trustlist](#input\_api\_access\_trustlist) | * `api_access_trustlist` - (Optional) Specifies the trustlist of network CIDRs that are allowed to access cluster APIs.<br/>  Specified when creating a CCE cluster. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>api_access_trustlist = ["10.0.0.0/32"]</pre> | `set(string)` | `null` | no |
| <a name="input_authenticating_proxy"></a> [authenticating\_proxy](#input\_authenticating\_proxy) | * `authenticating_proxy` - (Optional) Authenticating proxy configuration. Required if authentication\_mode is set to authenticating\_proxy.<br/>  ca          - X509 CA certificate configured in authenticating\_proxy mode. The maximum size of the certificate is 1 MB.<br/>  cert        - Client certificate issued by the X509 CA certificate configured in authenticating\_proxy mode.<br/>                This certificate is used for authentication from kube-apiserver to the extended API server.<br/>  private\_key - Private key of the client certificate issued by the X509 CA certificate configured in authenticating\_proxy mode.<br/>                This key is used for authentication from kube-apiserver to the extended API server.<br/><br/>Example input:<pre>authenticating_proxy = [<br/>  {<br/>    ca = filebase64("$$\{path.module}/certs/ca.crt")<br/>    cert = filebase64("$$\{path.module}/certs/server.crt")<br/>    private_key = filebase64("$$\{path.module}/certs/server.key")<br/>  }<br/>]</pre> | <pre>list(object({<br/>    ca          = optional(string)<br/>    cert        = optional(string)<br/>    private_key = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | * `authentication_mode`  - (Optional) Cluster authentication mode.<br/>  Clusters of Kubernetes v1.11 and earlier Possible values: x509, rbac, and authenticating\_proxy<br/>  Clusters of Kubernetes v1.13 and later Possible values: rbac and authenticating\_proxy<br/>  Default value: rbac Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>authentication_mode = "authenticating_proxy"</pre> | `string` | `"rbac"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | * `cluster_version` - (Optional) For the cluster version, possible values are v1.27, v1.25, v1.23, v1.21.<br/>  If this parameter is not set, the cluster of the latest version is created by default. Changing this parameter<br/>  will create a new cluster resource.<br/><br/>Example input:<br/>cluster\_version = "v1.30"<pre></pre> | `string` | `"v1.30"` | no |
| <a name="input_container_network_cidr"></a> [container\_network\_cidr](#input\_container\_network\_cidr) | * `container_network_cidr` - (Optional) Container network segment. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>container_network_cidr = "172.16.0.0/16"</pre> | `string` | `null` | no |
| <a name="input_delete_all_network"></a> [delete\_all\_network](#input\_delete\_all\_network) | * `delete_all_network` - (Optional) Specified whether to delete all associated network resources when deleting the CCE cluster.<br/>  Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_all_network = "true"</pre> | `string` | `null` | no |
| <a name="input_delete_all_storage"></a> [delete\_all\_storage](#input\_delete\_all\_storage) | * `delete_all_storage` - (Optional) Specified whether to delete all associated storage resources when deleting the CCE cluster.<br/>  Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_all_storage = "true"</pre> | `string` | `null` | no |
| <a name="input_delete_efs"></a> [delete\_efs](#input\_delete\_efs) | * `delete_efs` - (Optional) Specified whether to unbind associated SFS Turbo file systems when deleting the CCE cluster. Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_efs = "true"</pre> | `string` | `"false"` | no |
| <a name="input_delete_eni"></a> [delete\_eni](#input\_delete\_eni) | * `delete_eni` - (Optional) Specified whether to delete ENI ports when deleting the CCE cluster. Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_eni = "true"</pre> | `string` | `"false"` | no |
| <a name="input_delete_evs"></a> [delete\_evs](#input\_delete\_evs) | * `delete_evs`- (Optional) Specified whether to delete associated EVS disks when deleting the CCE cluster. Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_evs = "true"</pre> | `string` | `"false"` | no |
| <a name="input_delete_net"></a> [delete\_net](#input\_delete\_net) | * `delete_net` - (Optional) Specified whether to delete cluster Service/ingress-related resources, such as ELB when deleting the CCE cluster.<br/>  Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_net = "true"</pre> | `string` | `"false"` | no |
| <a name="input_delete_obs"></a> [delete\_obs](#input\_delete\_obs) | * `delete_obs` - (Optional) Specified whether to delete associated OBS buckets when deleting the CCE cluster. Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_obs = "true"</pre> | `string` | `"false"` | no |
| <a name="input_delete_sfs"></a> [delete\_sfs](#input\_delete\_sfs) | * `delete_sfs` - (Optional) Specified whether to delete associated SFS file systems when deleting the CCE cluster. Valid values are true, try and false. Default is false.<br/><br/>Example input:<pre>delete_sfs = "true"</pre> | `string` | `"false"` | no |
| <a name="input_description"></a> [description](#input\_description) | * `description` - (Optional) Cluster description.<br/><br/>Example input:<pre>description = "description"</pre> | `string` | `null` | no |
| <a name="input_eip"></a> [eip](#input\_eip) | * `eip` - (Optional) EIP address of the cluster.<br/><br/>Example input:<pre>eip = "80.158.47.13"</pre> | `string` | `null` | no |
| <a name="input_enable_volume_encryption"></a> [enable\_volume\_encryption](#input\_enable\_volume\_encryption) | * `enable_volume_encryption` - (Optional) System and data disks encryption of master nodes. Changing this parameter<br/>  will create a new cluster resource.<br/><br/>Example input:<pre>enable_volume_encryption = true</pre> | `bool` | `null` | no |
| <a name="input_eni_subnet_cidr"></a> [eni\_subnet\_cidr](#input\_eni\_subnet\_cidr) | * `eni_subnet_cidr` - (Optional) Specifies the ENI network segment. Specified when creating a CCE Turbo cluster. Changing this parameter will create a new cluster resource.<br/><br/>Example intput:<pre>eni_subnet_cidr = "10.0.0.0/24"</pre> | `string` | `null` | no |
| <a name="input_eni_subnet_id"></a> [eni\_subnet\_id](#input\_eni\_subnet\_id) | * `eni_subnet_id` - (Optional) Specifies the ENI subnet ID. Specified when creating a CCE Turbo cluster. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>eni_subnet_id = "opentelekomcloud_vpc_subnet_v1.eni_subnet.subnet_id"</pre> | `string` | `null` | no |
| <a name="input_extend_param"></a> [extend\_param](#input\_extend\_param) | * `extend_param` - (Optional) Extended parameter. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>extend_param = {<br/>  clusterAZ = "multi_az"<br/>}</pre> | `map(string)` | `null` | no |
| <a name="input_highway_subnet_id"></a> [highway\_subnet\_id](#input\_highway\_subnet\_id) | * `highway_subnet_id` - (Optional) The ID of the high speed network used to create bare metal nodes. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>highway_subnet_id = "opentelekomcloud_vpc_subnet_v1.highway_subnet.subnet_id"</pre> | `string` | `null` | no |
| <a name="input_ignore_addons"></a> [ignore\_addons](#input\_ignore\_addons) | * `ignore_addons` - (Optional) Skip all cluster addons operations.<br/><br/>Example input:<pre>ignore_addons = true</pre> | `bool` | `null` | no |
| <a name="input_ignore_certificate_clusters_data"></a> [ignore\_certificate\_clusters\_data](#input\_ignore\_certificate\_clusters\_data) | * `ignore_certificate_clusters_data` - (Optional) Skip sensitive cluster data.<br/><br/>Example input:<pre>ignore_certificate_clusters_data = true</pre> | `bool` | `null` | no |
| <a name="input_ignore_certificate_users_data"></a> [ignore\_certificate\_users\_data](#input\_ignore\_certificate\_users\_data) | * `ignore_certificate_users_data` - (Optional) Skip sensitive user data.<br/><br/>Example input:<pre>ignore_certificate_users_data = true</pre> | `bool` | `null` | no |
| <a name="input_kube_proxy_mode"></a> [kube\_proxy\_mode](#input\_kube\_proxy\_mode) | * `kube_proxy_mode` - - Service forwarding mode. Two modes are available:<br/>  * iptables: Traditional kube-proxy uses iptables rules to implement service load balancing. In this mode, too many iptables rules will be generated when many services are deployed.<br/>  In addition, non-incremental updates will cause a latency and even obvious performance issues in the case of heavy service traffic.<br/>  * ipvs: Optimized kube-proxy mode with higher throughput and faster speed. This mode supports incremental updates and can keep connections uninterrupted during service updates.<br/>  It is suitable for large-sized clusters.<br/><br/>Example input:<pre>kube_proxy_mode = "ipvs"</pre> | `string` | `null` | no |
| <a name="input_kubernetes_svc_ip_range"></a> [kubernetes\_svc\_ip\_range](#input\_kubernetes\_svc\_ip\_range) | * `kubernetes_svc_ip_range` - (Optional) Service CIDR block, or the IP address range which the kubernetes clusterIp must fall within.<br/>  This parameter is available only for clusters of v1.11.7 and later.<br/><br/>Example input:<pre>kubernetes_svc_ip_range = "10.247.0.0/16"</pre> | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | * `labels` - (Optional) Cluster tag, key/value pair format. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>labels = {<br/>  foo = "bar"<br/>}</pre> | `map(string)` | `null` | no |
| <a name="input_masters"></a> [masters](#input\_masters) | * `masters` - (Optional, List, ForceNew) Specifies the advanced configuration of master nodes. This parameter and multi\_az are alternative.<br/>  Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>masters = [<br/>    {<br/>      availability_zone = "eu-de-01"<br/>    },<br/>    {<br/>      availability_zone = "eu-de-02"<br/>    },<br/>    {<br/>      availability_zone = "eu-de-03"<br/>    },<br/>]</pre> | <pre>list(object({<br/>    availability_zone = string<br/>  }))</pre> | `null` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | * `multi_az` - (Optional) Enable multiple AZs for the cluster, only when using HA flavors. Changing this parameter will create a new cluster resource.<br/>  This parameter and masters are alternative.<br/><br/>Example input:<pre>multi_az = true</pre> | `bool` | `null` | no |
| <a name="input_no_addons"></a> [no\_addons](#input\_no\_addons) | * `no_addons` - (Optional) Remove addons installed by the default after the cluster creation.<br/><br/>Example input:<pre>no_addons = true</pre> | `bool` | `null` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | The following arguments are supported:<br/>* `cluster_id` - (Required, ForceNew, String) ID of the cluster. Changing this parameter will create a new resource.<br/>* `flavor` - (Required, ForceNew, String) Specifies the flavor id. Changing this parameter will create a new resource.<br/>* `availability_zone` - (Required, ForceNew, String) Specify the name of the available partition (AZ). If zone is not<br/>  specified than `node_pool` will be in randomly selected AZ. The default value is `random`. Changing<br/>  this parameter will create a new resource.<br/>-><br/>If AZ is set to `random`, when you create a node pool or update the number of nodes in a node pool, a scaling task is<br/>triggered. The system selects an AZ from all AZs where scaling is allowed to add nodes based on priorities. AZs with a<br/>smaller the number of existing nodes have a higher priority. If AZs have the same number of nodes, the system selects<br/>the AZ based on the AZ sequence. For more details see<br/>[API documentation](https://docs.otc.t-systems.com/en-us/api2/cce/cce_02_0354.html#cce_02_0354__table620623542313)<br/>* `key_pair` - (Optional, ForceNew, String) Key pair name when logging in to select the key pair mode.<br/>  This parameter and password are alternative. Changing this parameter will create a new resource.<br/>* `password` - (Optional, ForceNew, String) Key pair name when logging in to select the key pair mode.<br/>  This parameter and password are alternative. Changing this parameter will create a new resource.<br/>* `os` - (Optional, ForceNew, String) Node OS. Changing this parameter will create a new resource.<br/>  Supported OS depends on kubernetes version of the cluster.<br/>  \| OS           \| Kubernetes version \|<br/>  \| :----------- \| :----------------- \|<br/>  \| HCE OS 2.0   \| `v1.30`, `v1.29`, `v1.28`, `v1.27` \|<br/>  \| Ubuntu 22.04 \| `v1.30`, `v1.29`, `v1.28`, `v1.27` \|<br/>  \| EulerOS release 2.9 \| `v1.30`, `v1.29`, `v1.28`, `v1.27` \|<br/>  For detailed information, visit the CCE node operating systems [reference document](https://docs.otc.t-systems.com/cloud-container-engine/umn/nodes/node_oss.html).<br/>* `name` - (Required, String) Node Pool Name.<br/>* `initial_node_count` - (Required, Int) Initial number of expected nodes in the node pool.<br/>* `subnet_id` - (Optional, String, ForceNew) The ID of the subnet to which the NIC belongs. Changing this parameter will create a new resource.<br/>* `preinstall` - (Optional, String, ForceNew) Script required before installation. The input value can be a Base64 encoded string or not.<br/>  Changing this parameter will create a new resource.<br/>* `postinstall` - (Optional, String, ForceNew) Script required after installation. The input value can be a Base64 encoded string or not.<br/>  Changing this parameter will create a new resource.<br/>* `max_pods` - (Optional, Int, ForceNew) The maximum number of instances a node is allowed to create.<br/>  Changing this parameter will create a new node pool.<br/>* `docker_base_size` - (Optional, Int, ForceNew) Available disk space of a single Docker container on the node using the device mapper.<br/>  Changing this parameter will create a new node pool.<br/>* `docker_lvm_config_override` - (Optional, String, ForceNew) `ConfigMap` of the Docker data disk.<br/>  Changing this parameter will create a new node.<br/>* `scale_enable` - (Optional, Bool) Whether to enable auto scaling. If Autoscaler is enabled, install the autoscaler add-on to use the auto scaling feature.<br/>* `min_node_count` - (Optional, Int) Minimum number of nodes allowed if auto scaling is enabled.<br/>* `max_node_count` - (Optional, Int) Maximum number of nodes allowed if auto scaling is enabled.<br/>* `scale_down_cooldown_time` - (Optional, Int) Interval between two scaling operations, in minutes.<br/>* `server_group_reference` - (Optional, String, ForceNew) ECS group ID. If this parameter is specified, all nodes in the node pool will be created in this ECS group.<br/>* `security_group_ids` - (Optional, List, ForceNew) Specifies the list of custom security group IDs for the node pool.<br/>  If specified, the nodes will be put in these security groups. When specifying a security group, do not modify<br/>  the rules of the port on which CCE running depends.<br/>* `priority` - (Optional, Int) Weight of a node pool. A node pool with a higher weight has a higher priority during scaling.<br/>* `user_tags` - (Optional, Map, ForceNew) Tag of a VM, key/value pair format. Changing this parameter will create a new resource.<br/>* `k8s_tags` - (Optional, Map) Tags of a Kubernetes node, key/value pair format.<br/>* `runtime` - (Optional, String, ForceNew) Container runtime. Changing this parameter will create a new resource.<br/>              Use with high-caution, may trigger resource recreation. Options are:<br/>              `docker` - Docker<br/>              `containerd` - Containerd<br/>* `agency_name` - (Optional, String, ForceNew) IAM agency name. Changing this parameter will create a new resource.<br/>* `storage` - (Optional, String, ForceNew) Specifies the json string vary depending on CCE node pools storage options.<br/>  -> Please refer to the [documentation](https://docs.otc.t-systems.com/cloud-container-engine/api-ref/apis/cluster_management/querying_a_specified_node_pool.html#cce-02-0355-response-storage)<br/>  for actual fields.<br/>* `taints` - (Optional, List) Taints to created nodes to configure anti-affinity.<br/>  * `key` - (Required, String) A key must contain 1 to 63 characters starting with a letter or digit. Only letters, digits, hyphens (-), underscores (\_), and periods (.) are allowed. A DNS subdomain name can be used as the prefix of a key.<br/>  * `value` - (Required, String) A value must start with a letter or digit and can contain a maximum of 63 characters, including letters, digits, hyphens (-), underscores (\_), and periods (.).<br/>  * `effect` - (Optional, String) Available options are `NoSchedule`, `PreferNoSchedule`, and `NoExecute`.<br/>* `root_volume` - (Required, List, ForceNew) It corresponds to the system disk related configuration. Changing this parameter will create a new resource.<br/>  * `size` - (Required, Int, ForceNew) Disk size in GB.<br/>  * `volumetype` - (Required, String, ForceNew) Disk type.<br/>  * `extend_params` - (Optional, Map, ForceNew) Disk expansion parameters. A list of strings which describes additional disk parameters.<br/>  * `extend_param` **DEPRECATED** - (Optional, String, ForceNew) Disk expansion parameters.<br/>  Please use alternative parameter `extend_params`.<br/>  * `kms_id` - (Optional, String, ForceNew) The Encryption KMS ID of the system volume. By default, it tries to get from env by `OS_KMS_ID`.<br/>  -> **NOTE:** Common I/O (SATA) will reach end of life, end of 2025.<br/>* `data_volumes` - (Required, List, ForceNew) Represents the data disk to be created. Changing this parameter will create a new resource.<br/>  * `size` - (Required, Int, ForceNew) Disk size in GB.<br/>  * `volumetype` - (Required, String, ForceNew) Disk type.<br/>  * `extend_params` - (Optional, Map, ForceNew) Disk expansion parameters. A list of strings which describes additional disk parameters.<br/>  * `extend_param` **DEPRECATED** - (Optional, String, ForceNew) Disk expansion parameters.<br/>    Please use alternative parameter `extend_params`.<br/>  * `kms_id` - (Optional, String, ForceNew) The Encryption KMS ID of the data volume. By default, it tries to get from env by `OS_KMS_ID`.<br/>  -> **NOTE:** Common I/O (SATA) will reach end of life, end of 2025.<br/>-> To enable encryption with the KMS. Firstly, you need to create the agency to grant KMS rights to EVS.<br/>The agency has to be created for a new project first with a user who has security `admin` permissions.<br/>It is created automatically with the first encrypted EVS disk via UI.<br/><br/>Example input:<pre>node_pools = {<br/>  node_pool_1 = {<br/>    flavor             = "s3.large.2"<br/>    key_pair           = opentelekomcloud_compute_keypair_v2.create-keypair.name<br/>    os                 = "HCE OS 2.0"<br/>    name               = "node-pool-1"<br/>    availability_zone  = "eu-de-01"<br/>    initial_node_count = 1<br/>    max_node_count     = 2<br/>    root_volume = {<br/>      size       = 40<br/>      volumetype = "SSD"<br/>    }<br/>    data_volumes = [{<br/>      size       = 100<br/>      volumetype = "SSD"<br/>    }]<br/>  }<br/>}</pre> | <pre>map(object({<br/>    flavor                     = string<br/>    availability_zone          = optional(string, "random")<br/>    key_pair                   = optional(string)<br/>    password                   = optional(string)<br/>    os                         = string<br/>    name                       = string<br/>    initial_node_count         = number<br/>    subnet_id                  = optional(string)<br/>    preinstall                 = optional(string)<br/>    postinstall                = optional(string)<br/>    max_pods                   = optional(number)<br/>    docker_base_size           = optional(number)<br/>    docker_lvm_config_override = optional(string)<br/>    scale_enable               = optional(bool)<br/>    min_node_count             = optional(number)<br/>    max_node_count             = optional(number)<br/>    scale_down_cooldown_time   = optional(number)<br/>    server_group_reference     = optional(string)<br/>    security_group_ids         = optional(list(string))<br/>    priority                   = optional(number)<br/>    user_tags                  = optional(map(any))<br/>    k8s_tags                   = optional(map(any))<br/>    runtime                    = optional(string)<br/>    agency_name                = optional(string)<br/>    storage                    = optional(string)<br/><br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = optional(string)<br/>    })))<br/><br/>    root_volume = object({<br/>      size          = number<br/>      volumetype    = string<br/>      extend_params = optional(map(string))<br/>      kms_id        = optional(string)<br/>    })<br/><br/>    data_volumes = list(object({<br/>      size          = number<br/>      volumetype    = string<br/>      extend_params = optional(map(string))<br/>      kms_id        = optional(string)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | The following arguments are supported:<br/>* `cluster_id` - (Required, ForceNew, String) ID of the cluster. Changing this parameter will create a new resource.<br/>* `flavor_id` - (Required, ForceNew, String) Specifies the flavor id. Changing this parameter will create a new resource.<br/>* `availability_zone` - (Required, ForceNew, String) specify the name of the available partition (AZ). Changing this parameter will create a new resource.<br/>* `key_pair` - (Required, ForceNew, String) Key pair name when logging in to select the key pair mode. Changing this parameter will create a new resource.<br/>* `os` - (Optional, ForceNew, String) Node OS. Changing this parameter will create a new resource.<br/>  Supported OS depends on kubernetes version of the cluster.<br/>  \| OS           \| Kubernetes version \|<br/>  \| :----------- \| :----------------- \|<br/>  \| HCE OS 2.0   \| `v1.30`, `v1.29`, `v1.28`, `v1.27` \|<br/>  \| Ubuntu 22.04 \| `v1.30`, `v1.29`, `v1.28`, `v1.27` \|<br/>  \| EulerOS release 2.9 \| `v1.30`, `v1.29`, `v1.28`, `v1.27` \|<br/>  For detailed information, visit the CCE node operating systems [reference document](https://docs.otc.t-systems.com/cloud-container-engine/umn/nodes/node_oss.html).<br/>* `billing_mode` - (Optional, ForceNew, Int) Node's billing mode: The value is `0` (on demand). Changing this parameter will create a new resource.<br/>* `name` - (Optional, String) Node Name.<br/>* `subnet_id` - (Optional, ForceNew, String) The ID of the subnet to which the NIC belongs. Changing this parameter will create a new resource.<br/>* `labels` - (Optional, ForceNew, Map) Node tag, key/value pair format. Changing this parameter will create a new resource.<br/>* `tags` - (Optional, Map) The field is alternative to `labels`, key/value pair format.<br/>* `k8s_tags` - (Optional, ForceNew, Map) Tags of a Kubernetes node, key/value pair format.<br/>* `annotations` - (Optional, ForceNew, Map) Node annotation, key/value pair format. Changing this parameter will create a new resource<br/>* `runtime` - (Optional, ForceNew, String) Container runtime. Changing this parameter will create a new resource.<br/>              Use with high-caution, may trigger resource recreation. Options are:<br/>              `docker` - Docker<br/>              `containerd` - Containerd<br/>* `agency_name` - (Optional) IAM agency name. Changing this parameter will create a new resource.<br/>  -> **NOTE:** The IAM agency requires `tms:resourceTags:list` in order to properly read resource state.<br/>* `taints` - (Optional, ForceNew, List) Taints to created nodes to configure anti-affinity.<br/>  * `key` - (Required, String) A key must contain 1 to 63 characters starting with a letter or digit. Only letters, digits, hyphens (-), underscores (\_), and periods (.) are allowed. A DNS subdomain name can be used as the prefix of a key.<br/>  * `value` - (Required, String) A value must start with a letter or digit and can contain a maximum of 63 characters, including letters, digits, hyphens (-), underscores (\_), and periods (.).<br/>  * `effect` - (Optional, String) Available options are `NoSchedule`, `PreferNoSchedule`, and `NoExecute`.<br/>* `eip_ids` - (Optional, List) List of existing elastic IP IDs.<br/>-> If the `eip_ids` parameter is configured, you do not need to configure the `eip_count` and `bandwidth` parameters:<br/>`iptype`, `bandwidth_charge_mode`, `bandwidth_size` and `share_type`.<br/>* `eip_count` - (Optional, Int) Number of elastic IPs to be dynamically created.<br/>* `iptype` - (Optional, String) Elastic IP type.<br/>* `bandwidth_size` - (Optional, Int) Bandwidth size.<br/>-> If the `bandwidth_size` parameter is configured, you do not need to configure the<br/>  `eip_count`, `bandwidth_charge_mode`, `sharetype` and `iptype` parameters.<br/>* `bandwidth_charge_mode` - (Optional, String) Bandwidth billing type.<br/>* `sharetype` - (Optional, String) Bandwidth sharing type.<br/>* `extend_param_charging_mode` - (Optional, ForceNew, Int) Node charging mode, 0 is on-demand charging. Changing this parameter will create a new cluster resource.<br/>* `dedicated_host_id` - (Optional, String, ForceNew) Specifies the ID of the DeH to which the node is scheduled.<br/>* `ecs_performance_type` - (Optional, ForceNew, String) Classification of cloud server specifications. Changing this parameter will create a new cluster resource.<br/>* `order_id` - (Optional, ForceNew, String) Order ID, mandatory when the node payment type is the automatic payment package period type.<br/>  Changing this parameter will create a new cluster resource.<br/>* `product_id` - (Optional, ForceNew, String) The Product ID. Changing this parameter will create a new cluster resource.<br/>* `max_pods` - (Optional, ForceNew, Int) The maximum number of instances a node is allowed to create. Changing this parameter will create a new node resource.<br/>* `public_key` - (Optional, ForceNew, String) The Public key. Changing this parameter will create a new cluster resource.<br/>* `private_ip` - (Optional, ForceNew, String) Private IP of the CCE node. Changing this parameter will create a new resource.<br/>* `preinstall` - (Optional, ForceNew, String) Script required before installation. The input value can be a Base64 encoded string or not.<br/>  Changing this parameter will create a new resource.<br/>* `postinstall` - (Optional, ForceNew, String) Script required after installation. The input value can be a Base64 encoded string or not.<br/>  Changing this parameter will create a new resource.<br/>* `docker_base_size` - (Optional, ForceNew, Int) Available disk space of a single Docker container on the node using the device mapper.<br/>  Changing this parameter will create a new node.<br/>* `docker_lvm_config_override` - (Optional, ForceNew, String) `ConfigMap` of the Docker data disk.<br/>  Changing this parameter will create a new node.<br/>  Example:<br/>  `dockerThinpool=vgpaas/90%VG;kubernetesLV=vgpaas/10%VG;diskType=evs;lvType=linear`<br/>  In this example:<br/>  - `userLV`: size of the user space, for example, vgpaas/20%VG.<br/>  - `userPath`: mount path of the user space, for example, /home/wqt-test.<br/>  - `diskType`: disk type. Currently, only the evs, hdd, and ssd are supported.<br/>  - `lvType`: type of a logic volume. Currently, the value can be linear or striped.<br/>  - `dockerThinpool`: Docker space size, for example, vgpaas/60%VG.<br/>  - `kubernetesLV`: kubelet space size, for example, vgpaas/20%VG.<br/>* `root_volume` - (Required, ForceNew, List) It corresponds to the system disk related configuration. Changing this parameter will create a new resource.<br/>  * `size` - (Required, ForceNew, Int) Disk size in GB.<br/>  * `volumetype` - (Required, ForceNew, String) Disk type.<br/>  * `extend_params` - (Optional, ForceNew, Map) Disk expansion parameters. A list of strings which describes additional disk parameters.<br/>  * `extend_param` **DEPRECATED** - (Optional, ForceNew, String) Disk expansion parameters.<br/>  Please use alternative parameter `extend_params`.<br/>  * `kms_id` - (Optional, ForceNew, String) The Encryption KMS ID of the system volume. By default, it tries to get from env by `OS_KMS_ID`.<br/>  -> **NOTE:** Common I/O (SATA) will reach end of life, end of 2025.<br/>* `data_volumes` - (Required, ForceNew, List) Represents the data disk to be created. Changing this parameter will create a new resource.<br/>  * `size` - (Required, ForceNew, Int) Disk size in GB.<br/>  * `volumetype` - (Required, ForceNew, String) Disk type.<br/>  * `extend_params` - (Optional, ForceNew, Map) Disk expansion parameters. A list of strings which describes additional disk parameters.<br/>  * `extend_param` **DEPRECATED** - (Optional, ForceNew, String) Disk expansion parameters.<br/>  Please use alternative parameter `extend_params`.<br/>  * `kms_id` - (Optional, ForceNew, String) The Encryption KMS ID of the data volume. By default, it tries to get from env by `OS_KMS_ID`.<br/>  -> **NOTE:** Common I/O (SATA) will reach end of life, end of 2025.<br/>-> To enable encryption with the KMS. Firstly, you need to create the agency to grant KMS rights to EVS.<br/>The agency has to be created for a new project first with a user who has security `admin` permissions.<br/>It is created automatically with the first encrypted EVS disk via UI.<br/><br/>Example input:<pre>nodes = {<br/>  nodes_1 = {<br/>    name              = "node1"<br/>    availability_zone = "eu-de-01"<br/><br/>    os          = "EulerOS 2.9"<br/>    flavor_id   = "s2.large.2"<br/>    key_pair    = var.ssh_key<br/>    runtime     = "containerd"<br/>    agency_name = "test-agency"<br/><br/>    bandwidth_size = 100<br/><br/>    root_volume {<br/>      size       = 40<br/>      volumetype = "SATA"<br/>    }<br/><br/>    data_volumes {<br/>      size       = 100<br/>      volumetype = "SATA"<br/>    }<br/>    data_volumes {<br/>      size       = 100<br/>      volumetype = "SSD"<br/>      extend_params = {<br/>        "useType" = "docker"<br/>      }<br/>    }<br/>  }<br/>}</pre> | <pre>map(object({<br/>    flavor_id         = string<br/>    availability_zone = string<br/>    key_pair          = string<br/>    os                = optional(string)<br/>    name              = optional(string)<br/>    subnet_id         = optional(string)<br/>    labels            = optional(map(any))<br/>    tags              = optional(map(any))<br/>    k8s_tags          = optional(map(any))<br/>    annotations       = optional(map(any))<br/>    runtime           = optional(string)<br/>    agency_name       = optional(string)<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = optional(string)<br/>    })))<br/>    eip_ids                    = optional(set(string))<br/>    eip_count                  = optional(number)<br/>    iptype                     = optional(string)<br/>    bandwidth_size             = optional(number)<br/>    bandwidth_charge_mode      = optional(string)<br/>    sharetype                  = optional(string)<br/>    extend_param_charging_mode = optional(number)<br/>    dedicated_host_id          = optional(string)<br/>    ecs_performance_type       = optional(string)<br/>    order_id                   = optional(string)<br/>    product_id                 = optional(string)<br/>    max_pods                   = optional(number)<br/>    public_key                 = optional(string)<br/>    private_ip                 = optional(string)<br/>    preinstall                 = optional(string)<br/>    postinstall                = optional(string)<br/>    docker_base_size           = optional(number)<br/>    docker_lvm_config_override = optional(string)<br/><br/>    root_volume = object({<br/>      size          = number<br/>      volumetype    = string<br/>      extend_params = optional(map(string))<br/>      kms_id        = optional(string)<br/>    })<br/><br/>    data_volumes = list(object({<br/>      size          = number<br/>      volumetype    = string<br/>      extend_params = optional(map(string))<br/>      kms_id        = optional(string)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | * `security_group_id` - (Optional) Default worker node security group ID of the cluster. If specified, the cluster will be bound to the target security group.<br/>  Otherwise, the system will automatically create a default worker node security group for you. The default worker node security group needs to allow access<br/>  from certain ports to ensure normal communications. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>security_group_id = "opentelekomcloud_compute_secgroup_v2.name"</pre> | `string` | `null` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | * `timezone` - (Optional) Cluster timezone in string format. Changing this parameter will create a new cluster resource.<br/><br/>Example input:<pre>timezone = "UTC"</pre> | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cce_addon"></a> [cce\_addon](#output\_cce\_addon) | Use this data source to get from OpenTelekomCloud a CCE Addon template information.<br/><br/>* `name` - Installed add-on name.<br/>* `description` - Installed add-on description<br/><br/>Example output:<pre>output "addon_name" {<br/>  value = module.module_name.cce_addon.name<br/>}</pre> |
| <a name="output_cce_cluster"></a> [cce\_cluster](#output\_cce\_cluster) | Use this data source to get details about all clusters and obtains the certificate for accessing cluster information<br/><br/>* `id` - ID of the cluster resource.<br/>* `status` - Cluster status information.<br/>* `internal` - The internal network address.<br/>* `external` - The external network address.<br/>* `external_otc` - The endpoint of the cluster to be accessed through API Gateway.<br/>* `certificate_clusters/name` - The cluster name.<br/>* `certificate_clusters/server` - The server IP address.<br/>* `certificate_clusters/certificate_authority_data` - The certificate data.<br/>* `certificate_users/name` - The user name.<br/>* `certificate_users/client_certificate_data` - The client certificate data.<br/>* `certificate_users/client_key_data` - The client key data.<br/>* `installed_addons` - List of installed addon IDs. Empty if `ignore_addons` is `true`.<br/>* `security_group_control` - ID of the autogenerated security group for the CCE master port.<br/>* `security_group_node` - ID of the autogenerated security group for the CCE nodes.<br/><br/>Example output:<pre>output "cluster_id" {<br/>  value = module.module_name.cce_cluster.id<br/>}</pre> |
| <a name="output_cce_node"></a> [cce\_node](#output\_cce\_node) | Use this data source to get the specified node in a cluster from OpenTelekomCloud<br/><br/>* `status` - Node status information.<br/>* `server_id` - ID of the ECS where the node resides.<br/>* `public_ip` - Public IP of the CCE node.<br/><br/>Example output:<pre>output "node_status" {<br/>  value = module.module_name.cce_node.status<br/>}</pre> |
| <a name="output_node_pool"></a> [node\_pool](#output\_node\_pool) | Use this data source to get the specified node in a cluster from OpenTelekomCloud<br/><br/>* `status` - Node status information.<br/>* `id` - Specifies a resource ID in UUID format.<br/><br/>Example output:<pre>output = "node_pool_id" {<br/>  value = module.module_name.node_pool.id<br/>}</pre> |

## Modules

No modules.

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
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->