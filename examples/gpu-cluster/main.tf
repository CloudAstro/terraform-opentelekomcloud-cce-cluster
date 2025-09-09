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

data "opentelekomcloud_cce_addon_template_v3" "gpu-beta" {
  addon_name       = "gpu-beta"
  cluster_versions = "v1.30"
  addon_version    = "2.7.19"
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
  node_pools = {
    gpu_node_pool_1 = {
      flavor             = "pi2.2xlarge.4"
      key_pair           = resource.opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "HCE OS 2.0"
      name               = "gpu-node-pool-1"
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

    gpu_node_pool_2 = {
      flavor             = "pi2.2xlarge.4"
      key_pair           = resource.opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "HCE OS 2.0"
      name               = "gpu-node-pool-2"
      initial_node_count = 1
      max_node_count     = 3
      availability_zone  = "eu-de-03"
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


  addons = {
    gpu-beta = {
      template_name    = data.opentelekomcloud_cce_addon_template_v3.gpu-beta.addon_name
      template_version = data.opentelekomcloud_cce_addon_template_v3.gpu-beta.addon_version
      values = {
        basic = {
          obs_url        = "obs.eu-de.otc.t-systems.com"
          region         = "eu-de"
          device_version = data.opentelekomcloud_cce_addon_template_v3.gpu-beta.addon_name
          driver_version = data.opentelekomcloud_cce_addon_template_v3.gpu-beta.addon_name
          swr_addr       = data.opentelekomcloud_cce_addon_template_v3.gpu-beta.swr_addr
          swr_user       = data.opentelekomcloud_cce_addon_template_v3.gpu-beta.swr_user
        }
        custom = {
          compatible_with_legacy_api = true
          component_schedulername    = "kube-scheduler"
          disable_mount_path_v1      = false
          disable_nvidia_gsp         = true
          enable_fault_isolation     = true
          enable_health_monitoring   = true
          enable_metrics_monitoring  = true
          enable_simple_lib64_mount  = true
          enable_xgpu                = true
          metrics_delete_interval    = 30000
          metrics_monitor_interval   = 15000
          nvidia_driver_download_url = "https=//us.download.nvidia.com/tesla/535.129.03/NVIDIA-Linux-x86_64-535.129.03.run"
        }
      }
    }
  }
}
