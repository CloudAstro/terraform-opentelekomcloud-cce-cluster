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
