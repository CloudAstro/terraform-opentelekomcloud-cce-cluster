variable "addons" {
  type = map(object({
    template_name    = string
    template_version = optional(string)
    cluster_id       = optional(string)
    values = object({
      basic  = map(any)
      custom = map(any)
      flavor = optional(string)
    })
  }))
  default     = null
  description = <<DESCRIPTION
The following arguments are supported:
* `template_name` - (Required, String, ForceNew) Name of the add-on template to be installed, for example, `coredns`.
* `template_version` - (Required, String, ForceNew) Version number of the add-on to be installed or upgraded, for example, `v1.0.0`.
* `cluster_id` - (Required, String, ForceNew) ID of cluster to install the add-on on.
* `values` - (Required, List) Parameters of the template to be installed or upgraded.
    * `basic` - (Required, Map) Basic add-on information.
    * `custom` - (Required, Map) Custom parameters of the add-on.
    * `flavor` - (Optional, String) Specifies the json string vary depending on the add-on.

Example input:
```
addons = {
  autoscaling = {
    template_name    = "autoscaler"
    template_version = "1.30.18"
    values = {
        basic = {
          cceEndpoint = "https://cce.eu-de.otc.t-systems.com"
          ecsEndpoint = "https://ecs.eu-de.otc.t-systems.com"
          region      = "eu-de"
          swr_add     = "100.125.7.25:20202",
          swr_usr     = "cce-addons"
        }
        custom = {
          coresTotal                     = 32000
          expander                       = "priority"
          logLevel                       = 4
          maxEmptyBulkDeleteFlag         = 10
          maxNodeProvisionTime           = 15
          maxNodesTotal                  = 1000
          memoryTotal                    = 128000
          scaleDownDelayAfterAdd         = 10
          scaleDownDelayAfterDelete      = 11
          scaleDownDelayAfterFailure     = 3
          scaleDownEnabled               = true
          scaleDownUnneededTime          = 10
          scaleDownUtilizationThreshold  = 0.5
          scaleUpCpuUtilizationThreshold = 1
          scaleUpMemUtilizationThreshold = 1
          scaleUpUnscheduledPodEnabled   = true
          scaleUpUtilizationEnabled      = true
          tenant_id                      = ""
          unremovableNodeRecheckTimeout  = 5
        }
    }
  }
}
```
DESCRIPTION
}
