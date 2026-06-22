variable "node_attach" {
  type = map(object({
    server_id              = string
    os                     = string
    name                   = optional(string)
    node_pool_name         = optional(string)
    key_pair               = optional(string)
    password               = optional(string)
    private_key            = optional(string)
    runtime                = optional(string)
    max_pods               = optional(number)
    system_disk_kms_key_id = optional(string)
    docker_base_size       = optional(number)
    lvm_config             = optional(string)
    preinstall             = optional(string)
    postinstall            = optional(string)
    tags                   = optional(map(any))
    k8s_tags               = optional(map(any))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = optional(string)
    })))
    storage = optional(object({
      selectors = optional(list(object({
        name                           = string
        type                           = optional(string, "evs")
        match_label_size               = optional(string)
        match_label_volume_type        = optional(string)
        match_label_metadata_encrypted = optional(string)
        match_label_metadata_cmkid     = optional(string)
        match_label_count              = optional(string)
      })))
      groups = optional(list(object({
        name           = string
        cce_managed    = optional(bool, false)
        selector_names = list(string)
        virtual_spaces = list(object({
          name            = string
          size            = string
          lvm_lv_type     = optional(string)
          lvm_path        = optional(string)
          runtime_lv_type = optional(string)
        }))
      })))
    }))
  }))

  default     = null
  description = <<DESCRIPTION
Map of existing ECS instances to attach to the CCE cluster.

The following arguments are supported:
* `server_id` - (Required, ForceNew, String) The ECS server ID to attach. Changing this parameter will create a new resource.
* `os` - (Required, String) Operating system of the node. Changing this parameter will reset the node.
  Supported values: `EulerOS 2.5`, `EulerOS 2.9`, `Ubuntu 22.04`, `HCE OS 2.0`.
* `name` - (Optional, String) Node name.
* `key_pair` - (Optional, String) Key pair name for login. Alternative to `password`.
* `password` - (Optional, String) Root password for login. Alternative to `key_pair`.
  Must be 8-26 characters containing at least 3 of: uppercase, lowercase, digits, special characters (!@$%^-_=+[{}]:,./?~#*).
* `private_key` - (Optional, String) Private key of the key pair. Required when replacing or unbinding a keypair on an Active node.
* `runtime` - (Optional, String) Container runtime. Options: `docker`, `containerd`. Changing this parameter will reset the node.
* `max_pods` - (Optional, Int) Maximum number of pods allowed on the node. Changing this parameter will reset the node.
* `system_disk_kms_key_id` - (Optional, String) KMS key ID for root volume encryption. Changing this parameter will reset the node.
* `docker_base_size` - (Optional, Int) Available disk space in GB for a single container in device mapper mode. Changing this parameter will reset the node.
* `lvm_config` - (Optional, String) Docker data disk configuration. Alternative to `storage`.
  Example: `dockerThinpool=vgpaas/90%VG;kubernetesLV=vgpaas/10%VG`
  Changing this parameter will reset the node.
* `preinstall` - (Optional, String) Script to run before node installation. Accepts plain or Base64 encoded string. Changing this parameter will reset the node.
* `postinstall` - (Optional, String) Script to run after node installation. Accepts plain or Base64 encoded string. Changing this parameter will reset the node.
* `tags` - (Optional, Map) VM node tags, key/value pair format.
* `k8s_tags` - (Optional, Map) Kubernetes node tags, key/value pair format. Changing this parameter will reset the node.
* `annotations` - (Optional, Map) Node annotations, key/value pair format.
* `taints` - (Optional, List) Taints to configure anti-affinity. Changing this parameter will reset the node.
  * `key` - (Required, String) 1-63 characters, starting with letter or digit. Allows letters, digits, hyphens, underscores, periods.
  * `value` - (Required, String) Max 63 characters, starting with letter or digit. Allows letters, digits, hyphens, underscores, periods.
  * `effect` - (Optional, String) Options: `NoSchedule`, `PreferNoSchedule`, `NoExecute`.
* `storage` - (Optional) Disk initialization management. Alternative to `lvm_config`. Supported for clusters v1.15.11+. Changing this parameter will reset the node.
  * `selectors` - (Required, List) Disk selection rules.
    * `name` - (Required, String) Unique selector name, used as index in `selector_names`.
    * `type` - (Optional, String) Storage type. Currently only `evs` is supported. Default: `evs`.
    * `match_label_size` - (Optional, String) Matched disk size in GB. Example: `100`.
    * `match_label_volume_type` - (Optional, String) EVS disk type: `SSD`, `GPSSD`, or `SAS`.
    * `match_label_metadata_encrypted` - (Optional, String) Disk encryption flag: `0` = not encrypted, `1` = encrypted.
    * `match_label_metadata_cmkid` - (Optional, String) Customer master key ID for encrypted disks.
    * `match_label_count` - (Optional, String) Number of disks to select. If omitted, all matching disks are selected.
  * `groups` - (Required, List) Storage groups dividing disk space.
    * `name` - (Required, String) Unique virtual storage group name.
    * `cce_managed` - (Optional, Bool) Whether this group is for Kubernetes and runtime components. Only one group can be `true`. Default: `false`.
    * `selector_names` - (Required, List) List of selector names to match. A selector can only belong to one group.
    * `virtual_spaces` - (Required, List) Space configuration within the group.
      * `name` - (Required, String) Virtual space name: `kubernetes`, `runtime`, or `user`.
      * `size` - (Required, String) Percentage of space. Example: `90%`. Total across all virtual spaces cannot exceed 100%.
      * `lvm_lv_type` - (Optional, String) LVM write mode: `linear` or `striped`. Applies to `kubernetes` and `user` only.
      * `lvm_path` - (Optional, String) Absolute mount path. Applies to `user` only.
      * `runtime_lv_type` - (Optional, String) LVM write mode: `linear` or `striped`. Applies to `runtime` only.

Example input:
```
node_attach = {
  vg-one-0 = {
    server_id = "ecs-uuid-0"
    os = "HCE OS 2.0"
    key_pair = "my-keypair"
    runtime = "containerd"
    k8s_tags = { 
      role = "vg-one" 
    }
    taints = [{
      key = "dedicated"
      value = "vg-one"
      effect = "NoSchedule"
    }]
  }
  vg-one-1 = {
    server_id = "ecs-uuid-1"
    os = "HCE OS 2.0"
    key_pair = "my-keypair"
    runtime = "containerd"
    storage = {
      selectors = [{
        name = "data-disk"
        type = "evs"
        match_label_volume_type = "SSD"
        match_label_count = "1"
      }]
      groups = [{
        name = "vgpaas"
        cce_managed = true
        selector_names = ["data-disk"]
        virtual_spaces = [
          { name = "kubernetes", size = "10%", lvm_lv_type = "linear" },
          { name = "runtime", size = "90%", runtime_lv_type = "linear" }
        ]
      }]
    }
  }
}
```
DESCRIPTION
}