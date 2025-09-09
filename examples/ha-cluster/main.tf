data "opentelekomcloud_identity_project_v3" "current" {}


module "vpc" {
  source      = "CloudAstro/vpc/opentelekomcloud"
  version     = "1.0.0"
  name        = "vpc"
  description = "description"
  cidr        = "10.0.0.0/16"
}

module "snet" {
  source      = "CloudAstro/vpc-subnet/opentelekomcloud"
  name        = "snet"
  description = "description"
  cidr        = "10.0.0.0/24"
  gateway_ip  = "10.0.0.1"
  vpc_id      = module.vpc.vpc_v1.id
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


data "opentelekomcloud_cce_addon_template_v3" "autoscaler" {
  addon_name       = "autoscaler"
  cluster_versions = "v1.30"
  addon_version    = "1.30.18"
}


module "cce" {
  source                 = "../../"
  name                   = "cce-cluster"
  vpc_id                 = module.vpc.vpc_v1.id
  subnet_id              = module.snet.vpc_subnet.network_id
  container_network_type = "overlay_l2"
  cluster_type           = "VirtualMachine"
  flavor_id              = "cce.s2.small"
  eip                    = module.eip.vpc_eip.publicip[0].ip_address
  masters = [{
    availability_zone = "eu-de-01"
    },
    {
      availability_zone = "eu-de-02"
    },
    {
      availability_zone = "eu-de-03"
    },
  ]
  node_pools = {
    node_pool_1 = {
      flavor             = "s3.large.2"
      key_pair           = resource.opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "HCE OS 2.0"
      name               = "node-pool-1"
      initial_node_count = 1
      max_node_count     = 3
      availability_zone  = "eu-de-01"
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
      key_pair           = resource.opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "HCE OS 2.0"
      name               = "node-pool-2"
      initial_node_count = 1
      max_node_count     = 3
      availability_zone  = "eu-de-02"
      root_volume = {
        size       = 40
        volumetype = "SSD"
      }
      data_volumes = [{
        size       = 100
        volumetype = "SSD"
      }]

      node_pool_3 = {
        flavor             = "s3.large.2"
        key_pair           = resource.opentelekomcloud_compute_keypair_v2.create-keypair.name
        os                 = "HCE OS 2.0"
        name               = "node-pool-3"
        availability_zone  = "eu-de-03"
        initial_node_count = 1
        max_node_count     = 3
        root_volume = {
          size       = 40
          volumetype = "SSD"
        }
        data_volumes = [{
          size       = 100
          volumetype = "SSD"
        }]
    } }
  }
  addons = {
    autoscaling = {
      template_name    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_name
      template_version = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_version
      values = {
        basic = {
          cceEndpoint = "https://cce.eu-de.otc.t-systems.com"
          ecsEndpoint = "https://ecs.eu-de.otc.t-systems.com"
          region      = "eu-de"
          swr_add     = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_addr
          swr_usr     = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_user
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
          tenant_id                      = data.opentelekomcloud_identity_project_v3.current.id
          unremovableNodeRecheckTimeout  = 5
        }
      }
    }
  }
}
