variable "name" {
  type        = string
  description = <<DESCRIPTION
* `name` - (Required) Cluster name. Changing this parameter will create a new cluster resource.

Example input:
```
name = "cce-cluster"
```
DESCRIPTION
}

variable "labels" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
* `labels` - (Optional) Cluster tag, key/value pair format. Changing this parameter will create a new cluster resource.

Example input:
```
labels = {
  foo = "bar"
}
```
DESCRIPTION
}

variable "annotations" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
* `annotations` - (Optional) Cluster annotation, key/value pair format. Changing this parameter will create a new cluster resource.

Example input:
```
annotations = {
  foo = "bar"
}
```
DESCRIPTION
}

variable "timezone" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `timezone` - (Optional) Cluster timezone in string format. Changing this parameter will create a new cluster resource.

Example input:
```
timezone = "UTC"
```
DESCRIPTION
}


variable "flavor_id" {
  type        = string
  description = <<DESCRIPTION
* `flavor_id` - (Required) Cluster specifications. Changing this parameter will create a new cluster resource.
   cce.s1.small - small-scale single cluster (up to 50 nodes).
   cce.s1.medium - medium-scale single cluster (up to 200 nodes).
   cce.s2.small - small-scale HA cluster (up to 50 nodes).
   cce.s2.medium - medium-scale HA cluster (up to 200 nodes).
   cce.s2.large - large-scale HA cluster (up to 1000 nodes).
   cce.s2.xlarge - ultra-large-scale, high availability cluster (<= 2,000 nodes).

Example input:
```
flavor_id = "cce.s1.small"
```
DESCRIPTION
}

variable "cluster_version" {
  type        = string
  default     = "v1.30"
  description = <<DESCRIPTION
* `cluster_version` - (Optional) For the cluster version, possible values are v1.27, v1.25, v1.23, v1.21.
  If this parameter is not set, the cluster of the latest version is created by default. Changing this parameter
  will create a new cluster resource.

Example input:
cluster_version = "v1.30"
```
```
DESCRIPTION
}

variable "cluster_type" {
  type        = string
  description = <<DESCRIPTION
* `cluster_type` - (Required) Cluster Type, possible values are VirtualMachine and BareMetal. Changing this parameter will create a new cluster resource.

Example input:
```
cluster_type = "VirtualMachine"
```
DESCRIPTION
}

variable "description" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `description` - (Optional) Cluster description.

Example input:
```
description = "description"
```
DESCRIPTION
}



variable "extend_param" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
* `extend_param` - (Optional) Extended parameter. Changing this parameter will create a new cluster resource.

Example input:
```
extend_param = {
  clusterAZ = "multi_az"
}
```
DESCRIPTION
}

variable "enable_volume_encryption" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
* `enable_volume_encryption` - (Optional) System and data disks encryption of master nodes. Changing this parameter
  will create a new cluster resource.

Example input:
```
enable_volume_encryption = true
```
DESCRIPTION
}

variable "vpc_id" {
  type        = string
  description = <<DESCRIPTION
* `vpc_id` - - (Required) The ID of the VPC used to create the node. Changing this parameter will create a new cluster resource.

Example input:
```
vpc_id = opentelekomcloud_vpc_v1.example.id
```
DESCRIPTION
}

variable "subnet_id" {
  type        = string
  description = <<DESCRIPTION
* `subnet_id` - (Required) The Network ID of the subnet used to create the node. Changing this parameter will create a new cluster resource.

Example input:
```
subnet_id = opentelekomcloud_vpc_subnet_v1.example.subnet_id
```
DESCRIPTION
}

variable "security_group_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `security_group_id` - (Optional) Default worker node security group ID of the cluster. If specified, the cluster will be bound to the target security group.
  Otherwise, the system will automatically create a default worker node security group for you. The default worker node security group needs to allow access
  from certain ports to ensure normal communications. Changing this parameter will create a new cluster resource.

Example input:
```
security_group_id = "opentelekomcloud_compute_secgroup_v2.name"
```
DESCRIPTION
}

variable "highway_subnet_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `highway_subnet_id` - (Optional) The ID of the high speed network used to create bare metal nodes. Changing this parameter will create a new cluster resource.

Example input:
```
highway_subnet_id = "opentelekomcloud_vpc_subnet_v1.highway_subnet.subnet_id"
```
DESCRIPTION
}

variable "container_network_type" {
  type = string
  validation {
    condition     = contains(["overlay_l2", "vpc-router", "eni", "underlay_ipvlan"], var.container_network_type)
    error_message = "Should either contain overlay_l2, vpc-router, eni, underlay_ipvlan"
  }
  description = <<DESCRIPTION
* `container_network_type` - (Required) Container network type.
  overlay_l2 - An overlay_l2 network built for containers by using Open vSwitch(OVS).
  vpc-router - A vpc-router network built for containers by using ipvlan and custom VPC routes.
  eni - Cloud native 2.0 network model which integrates the native ENI capability of VPC.
  underlay_ipvlan - An underlay_ipvlan network built for bare metal servers by using ipvlan.

Example input:
```
container_network_type = "overlay_l2"
```
DESCRIPTION
}

variable "container_network_cidr" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `container_network_cidr` - (Optional) Container network segment. Changing this parameter will create a new cluster resource.

Example input:
```
container_network_cidr = "172.16.0.0/16"
```
DESCRIPTION
}

variable "eni_subnet_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `eni_subnet_id` - (Optional) Specifies the ENI subnet ID. Specified when creating a CCE Turbo cluster. Changing this parameter will create a new cluster resource.

Example input:
```
eni_subnet_id = "opentelekomcloud_vpc_subnet_v1.eni_subnet.subnet_id"
```
DESCRIPTION
}


variable "eni_subnet_cidr" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `eni_subnet_cidr` - (Optional) Specifies the ENI network segment. Specified when creating a CCE Turbo cluster. Changing this parameter will create a new cluster resource.

Example intput:
```
eni_subnet_cidr = "10.0.0.0/24"
```
DESCRIPTION
}

variable "api_access_trustlist" {
  type        = set(string)
  default     = null
  description = <<DESCRIPTION
* `api_access_trustlist` - (Optional) Specifies the trustlist of network CIDRs that are allowed to access cluster APIs.
  Specified when creating a CCE cluster. Changing this parameter will create a new cluster resource.

Example input:
```
api_access_trustlist = ["10.0.0.0/32"]
```
DESCRIPTION
}

variable "authentication_mode" {
  type        = string
  default     = "rbac"
  description = <<DESCRIPTION
* `authentication_mode`  - (Optional) Cluster authentication mode.
  Clusters of Kubernetes v1.11 and earlier Possible values: x509, rbac, and authenticating_proxy
  Clusters of Kubernetes v1.13 and later Possible values: rbac and authenticating_proxy
  Default value: rbac Changing this parameter will create a new cluster resource.

Example input:
```
authentication_mode = "authenticating_proxy"
```
DESCRIPTION
}

variable "authenticating_proxy" {
  type = list(object({
    ca          = optional(string)
    cert        = optional(string)
    private_key = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
* `authenticating_proxy` - (Optional) Authenticating proxy configuration. Required if authentication_mode is set to authenticating_proxy.
  ca          - X509 CA certificate configured in authenticating_proxy mode. The maximum size of the certificate is 1 MB.
  cert        - Client certificate issued by the X509 CA certificate configured in authenticating_proxy mode.
                This certificate is used for authentication from kube-apiserver to the extended API server.
  private_key - Private key of the client certificate issued by the X509 CA certificate configured in authenticating_proxy mode.
                This key is used for authentication from kube-apiserver to the extended API server.

Example input:
```
authenticating_proxy = [
  {
    ca = filebase64("$$\{path.module}/certs/ca.crt")
    cert = filebase64("$$\{path.module}/certs/server.crt")
    private_key = filebase64("$$\{path.module}/certs/server.key")
  }
]
```
DESCRIPTION
}

variable "multi_az" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
* `multi_az` - (Optional) Enable multiple AZs for the cluster, only when using HA flavors. Changing this parameter will create a new cluster resource.
  This parameter and masters are alternative.

Example input:
```
multi_az = true
```
DESCRIPTION
}

variable "masters" {
  type = list(object({
    availability_zone = string
  }))
  default     = null
  description = <<DESCRIPTION
* `masters` - (Optional, List, ForceNew) Specifies the advanced configuration of master nodes. This parameter and multi_az are alternative.
  Changing this parameter will create a new cluster resource.

Example input:
```
masters = [
    {
      availability_zone = "eu-de-01"
    },
    {
      availability_zone = "eu-de-02"
    },
    {
      availability_zone = "eu-de-03"
    },
]
```
DESCRIPTION
}

variable "eip" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `eip` - (Optional) EIP address of the cluster.

Example input:
```
eip = "80.158.47.13"
```
DESCRIPTION
}

variable "kubernetes_svc_ip_range" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `kubernetes_svc_ip_range` - (Optional) Service CIDR block, or the IP address range which the kubernetes clusterIp must fall within.
  This parameter is available only for clusters of v1.11.7 and later.

Example input:
```
kubernetes_svc_ip_range = "10.247.0.0/16"
```
DESCRIPTION
}

variable "no_addons" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
* `no_addons` - (Optional) Remove addons installed by the default after the cluster creation.

Example input:
```
no_addons = true
```
DESCRIPTION
}

variable "ignore_addons" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
* `ignore_addons` - (Optional) Skip all cluster addons operations.

Example input:
```
ignore_addons = true
```
DESCRIPTION
}

variable "ignore_certificate_users_data" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
* `ignore_certificate_users_data` - (Optional) Skip sensitive user data.

Example input:
```
ignore_certificate_users_data = true
```
DESCRIPTION
}

variable "ignore_certificate_clusters_data" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
* `ignore_certificate_clusters_data` - (Optional) Skip sensitive cluster data.

Example input:
```
ignore_certificate_clusters_data = true
```
DESCRIPTION
}

variable "kube_proxy_mode" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `kube_proxy_mode` - - Service forwarding mode. Two modes are available:
  * iptables: Traditional kube-proxy uses iptables rules to implement service load balancing. In this mode, too many iptables rules will be generated when many services are deployed.
  In addition, non-incremental updates will cause a latency and even obvious performance issues in the case of heavy service traffic.
  * ipvs: Optimized kube-proxy mode with higher throughput and faster speed. This mode supports incremental updates and can keep connections uninterrupted during service updates.
  It is suitable for large-sized clusters.

Example input:
```
kube_proxy_mode = "ipvs"
```
DESCRIPTION
}

variable "delete_evs" {
  type        = string
  default     = "false"
  description = <<DESCRIPTION
* `delete_evs`- (Optional) Specified whether to delete associated EVS disks when deleting the CCE cluster. Valid values are true, try and false. Default is false.

Example input:
```
delete_evs = "true"
```
DESCRIPTION
}

variable "delete_obs" {
  type        = string
  default     = "false"
  description = <<DESCRIPTION
* `delete_obs` - (Optional) Specified whether to delete associated OBS buckets when deleting the CCE cluster. Valid values are true, try and false. Default is false.

Example input:
```
delete_obs = "true"
```
DESCRIPTION
}

variable "delete_sfs" {
  type        = string
  default     = "false"
  description = <<DESCRIPTION
* `delete_sfs` - (Optional) Specified whether to delete associated SFS file systems when deleting the CCE cluster. Valid values are true, try and false. Default is false.

Example input:
```
delete_sfs = "true"
```
DESCRIPTION
}

variable "delete_efs" {
  type        = string
  default     = "false"
  description = <<DESCRIPTION
* `delete_efs` - (Optional) Specified whether to unbind associated SFS Turbo file systems when deleting the CCE cluster. Valid values are true, try and false. Default is false.

Example input:
```
delete_efs = "true"
```
DESCRIPTION
}

variable "delete_eni" {
  type        = string
  default     = "false"
  description = <<DESCRIPTION
* `delete_eni` - (Optional) Specified whether to delete ENI ports when deleting the CCE cluster. Valid values are true, try and false. Default is false.

Example input:
```
delete_eni = "true"
```
DESCRIPTION
}

variable "delete_net" {
  type        = string
  default     = "false"
  description = <<DESCRIPTION
* `delete_net` - (Optional) Specified whether to delete cluster Service/ingress-related resources, such as ELB when deleting the CCE cluster.
  Valid values are true, try and false. Default is false.

Example input:
```
delete_net = "true"
```
DESCRIPTION
}

variable "delete_all_storage" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `delete_all_storage` - (Optional) Specified whether to delete all associated storage resources when deleting the CCE cluster.
  Valid values are true, try and false. Default is false.

Example input:
```
delete_all_storage = "true"
```
DESCRIPTION
}

variable "delete_all_network" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `delete_all_network` - (Optional) Specified whether to delete all associated network resources when deleting the CCE cluster.
  Valid values are true, try and false. Default is false.

Example input:
```
delete_all_network = "true"
```
DESCRIPTION
}
