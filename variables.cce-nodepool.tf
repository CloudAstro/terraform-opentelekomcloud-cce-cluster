variable "node_pools" {
  type = map(object({
    flavor                     = string
    availability_zone          = optional(string, "random")
    key_pair                   = optional(string)
    password                   = optional(string)
    os                         = string
    name                       = string
    initial_node_count         = number
    subnet_id                  = optional(string)
    preinstall                 = optional(string)
    postinstall                = optional(string)
    max_pods                   = optional(number)
    docker_base_size           = optional(number)
    docker_lvm_config_override = optional(string)
    scale_enable               = optional(bool)
    min_node_count             = optional(number)
    max_node_count             = optional(number)
    scale_down_cooldown_time   = optional(number)
    server_group_reference     = optional(string)
    security_group_ids         = optional(list(string))
    priority                   = optional(number)
    user_tags                  = optional(map(any))
    k8s_tags                   = optional(map(any))
    runtime                    = optional(string)
    agency_name                = optional(string)
    storage                    = optional(string)

    taints = optional(list(object({
      key    = string
      value  = string
      effect = optional(string)
    })))

    root_volume = object({
      size          = number
      volumetype    = string
      extend_params = optional(map(string))
      kms_id        = optional(string)
    })

    data_volumes = list(object({
      size          = number
      volumetype    = string
      extend_params = optional(map(string))
      kms_id        = optional(string)
    }))
  }))

  default = null

  validation {
    condition = var.node_pools == null ? true : alltrue([

      for pool in values(var.node_pools) :
      (
        (pool.key_pair != null && pool.password == null) ||
        (pool.key_pair == null && pool.password != null)
      )
    ])
    error_message = "Exactly one of 'key_pair' or 'password' must be defined for each node pool."
  }

  description = <<DESCRIPTION
The following arguments are supported:
* `cluster_id` - (Required, ForceNew, String) ID of the cluster. Changing this parameter will create a new resource.
* `flavor` - (Required, ForceNew, String) Specifies the flavor id. Changing this parameter will create a new resource.
* `availability_zone` - (Required, ForceNew, String) Specify the name of the available partition (AZ). If zone is not
  specified than `node_pool` will be in randomly selected AZ. The default value is `random`. Changing
  this parameter will create a new resource.
->
If AZ is set to `random`, when you create a node pool or update the number of nodes in a node pool, a scaling task is
triggered. The system selects an AZ from all AZs where scaling is allowed to add nodes based on priorities. AZs with a
smaller the number of existing nodes have a higher priority. If AZs have the same number of nodes, the system selects
the AZ based on the AZ sequence. For more details see
[API documentation](https://docs.otc.t-systems.com/en-us/api2/cce/cce_02_0354.html#cce_02_0354__table620623542313)
* `key_pair` - (Optional, ForceNew, String) Key pair name when logging in to select the key pair mode.
  This parameter and password are alternative. Changing this parameter will create a new resource.
* `password` - (Optional, ForceNew, String) Key pair name when logging in to select the key pair mode.
  This parameter and password are alternative. Changing this parameter will create a new resource.
* `os` - (Optional, ForceNew, String) Node OS. Changing this parameter will create a new resource.
  Supported OS depends on kubernetes version of the cluster.
  | OS           | Kubernetes version |
  | :----------- | :----------------- |
  | HCE OS 2.0   | `v1.30`, `v1.29`, `v1.28`, `v1.27` |
  | Ubuntu 22.04 | `v1.30`, `v1.29`, `v1.28`, `v1.27` |
  | EulerOS release 2.9 | `v1.30`, `v1.29`, `v1.28`, `v1.27` |
  For detailed information, visit the CCE node operating systems [reference document](https://docs.otc.t-systems.com/cloud-container-engine/umn/nodes/node_oss.html).
* `name` - (Required, String) Node Pool Name.
* `initial_node_count` - (Required, Int) Initial number of expected nodes in the node pool.
* `subnet_id` - (Optional, String, ForceNew) The ID of the subnet to which the NIC belongs. Changing this parameter will create a new resource.
* `preinstall` - (Optional, String, ForceNew) Script required before installation. The input value can be a Base64 encoded string or not.
  Changing this parameter will create a new resource.
* `postinstall` - (Optional, String, ForceNew) Script required after installation. The input value can be a Base64 encoded string or not.
  Changing this parameter will create a new resource.
* `max_pods` - (Optional, Int, ForceNew) The maximum number of instances a node is allowed to create.
  Changing this parameter will create a new node pool.
* `docker_base_size` - (Optional, Int, ForceNew) Available disk space of a single Docker container on the node using the device mapper.
  Changing this parameter will create a new node pool.
* `docker_lvm_config_override` - (Optional, String, ForceNew) `ConfigMap` of the Docker data disk.
  Changing this parameter will create a new node.
* `scale_enable` - (Optional, Bool) Whether to enable auto scaling. If Autoscaler is enabled, install the autoscaler add-on to use the auto scaling feature.
* `min_node_count` - (Optional, Int) Minimum number of nodes allowed if auto scaling is enabled.
* `max_node_count` - (Optional, Int) Maximum number of nodes allowed if auto scaling is enabled.
* `scale_down_cooldown_time` - (Optional, Int) Interval between two scaling operations, in minutes.
* `server_group_reference` - (Optional, String, ForceNew) ECS group ID. If this parameter is specified, all nodes in the node pool will be created in this ECS group.
* `security_group_ids` - (Optional, List, ForceNew) Specifies the list of custom security group IDs for the node pool.
  If specified, the nodes will be put in these security groups. When specifying a security group, do not modify
  the rules of the port on which CCE running depends.
* `priority` - (Optional, Int) Weight of a node pool. A node pool with a higher weight has a higher priority during scaling.
* `user_tags` - (Optional, Map, ForceNew) Tag of a VM, key/value pair format. Changing this parameter will create a new resource.
* `k8s_tags` - (Optional, Map) Tags of a Kubernetes node, key/value pair format.
* `runtime` - (Optional, String, ForceNew) Container runtime. Changing this parameter will create a new resource.
              Use with high-caution, may trigger resource recreation. Options are:
              `docker` - Docker
              `containerd` - Containerd
* `agency_name` - (Optional, String, ForceNew) IAM agency name. Changing this parameter will create a new resource.
* `storage` - (Optional, String, ForceNew) Specifies the json string vary depending on CCE node pools storage options.
  -> Please refer to the [documentation](https://docs.otc.t-systems.com/cloud-container-engine/api-ref/apis/cluster_management/querying_a_specified_node_pool.html#cce-02-0355-response-storage)
  for actual fields.
* `taints` - (Optional, List) Taints to created nodes to configure anti-affinity.
  * `key` - (Required, String) A key must contain 1 to 63 characters starting with a letter or digit. Only letters, digits, hyphens (-), underscores (_), and periods (.) are allowed. A DNS subdomain name can be used as the prefix of a key.
  * `value` - (Required, String) A value must start with a letter or digit and can contain a maximum of 63 characters, including letters, digits, hyphens (-), underscores (_), and periods (.).
  * `effect` - (Optional, String) Available options are `NoSchedule`, `PreferNoSchedule`, and `NoExecute`.
* `root_volume` - (Required, List, ForceNew) It corresponds to the system disk related configuration. Changing this parameter will create a new resource.
  * `size` - (Required, Int, ForceNew) Disk size in GB.
  * `volumetype` - (Required, String, ForceNew) Disk type.
  * `extend_params` - (Optional, Map, ForceNew) Disk expansion parameters. A list of strings which describes additional disk parameters.
  * `extend_param` **DEPRECATED** - (Optional, String, ForceNew) Disk expansion parameters.
  Please use alternative parameter `extend_params`.
  * `kms_id` - (Optional, String, ForceNew) The Encryption KMS ID of the system volume. By default, it tries to get from env by `OS_KMS_ID`.
  -> **NOTE:** Common I/O (SATA) will reach end of life, end of 2025.
* `data_volumes` - (Required, List, ForceNew) Represents the data disk to be created. Changing this parameter will create a new resource.
  * `size` - (Required, Int, ForceNew) Disk size in GB.
  * `volumetype` - (Required, String, ForceNew) Disk type.
  * `extend_params` - (Optional, Map, ForceNew) Disk expansion parameters. A list of strings which describes additional disk parameters.
  * `extend_param` **DEPRECATED** - (Optional, String, ForceNew) Disk expansion parameters.
    Please use alternative parameter `extend_params`.
  * `kms_id` - (Optional, String, ForceNew) The Encryption KMS ID of the data volume. By default, it tries to get from env by `OS_KMS_ID`.
  -> **NOTE:** Common I/O (SATA) will reach end of life, end of 2025.
-> To enable encryption with the KMS. Firstly, you need to create the agency to grant KMS rights to EVS.
The agency has to be created for a new project first with a user who has security `admin` permissions.
It is created automatically with the first encrypted EVS disk via UI.

Example input:
```
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
}
```
DESCRIPTION
}
