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
  name = "new-keypair-turbo"
}

module "cce" {
  source                 = "../../"
  name                   = "cce-cluster"
  vpc_id                 = module.vpc.vpc_v1.id
  subnet_id              = module.snet.vpc_subnet.network_id
  eni_subnet_id          = module.snet.vpc_subnet.subnet_id
  eni_subnet_cidr        = module.snet.vpc_subnet.cidr
  container_network_type = "eni"
  cluster_type           = "VirtualMachine"
  flavor_id              = "cce.s1.small"
  eip                    = module.eip.vpc_eip.publicip[0].ip_address
  node_pools = {
    node_pool_1 = {
      flavor             = "s7n.xlarge.2"
      key_pair           = resource.opentelekomcloud_compute_keypair_v2.create-keypair.name
      os                 = "Ubuntu 22.04"
      name               = "node-pool-1"
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
    }
  }
}
