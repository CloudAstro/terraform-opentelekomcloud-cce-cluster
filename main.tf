resource "opentelekomcloud_cce_cluster_v3" "cluster" {
  name                             = var.name
  labels                           = var.labels
  annotations                      = var.annotations
  timezone                         = var.timezone
  flavor_id                        = var.flavor_id
  cluster_version                  = var.cluster_version
  cluster_type                     = var.cluster_type
  description                      = var.description
  extend_param                     = var.extend_param
  enable_volume_encryption         = var.enable_volume_encryption
  vpc_id                           = var.vpc_id
  subnet_id                        = var.subnet_id
  security_group_id                = var.security_group_id
  highway_subnet_id                = var.highway_subnet_id
  container_network_type           = var.container_network_type
  container_network_cidr           = var.container_network_cidr
  eni_subnet_id                    = var.eni_subnet_id
  eni_subnet_cidr                  = var.eni_subnet_cidr
  api_access_trustlist             = var.api_access_trustlist
  authentication_mode              = var.authentication_mode
  eip                              = var.eip
  kubernetes_svc_ip_range          = var.kubernetes_svc_ip_range
  no_addons                        = var.no_addons
  multi_az                         = var.multi_az
  ignore_addons                    = var.ignore_addons
  ignore_certificate_users_data    = var.ignore_certificate_users_data
  ignore_certificate_clusters_data = var.ignore_certificate_clusters_data
  kube_proxy_mode                  = var.kube_proxy_mode
  delete_evs                       = var.delete_all_storage != null || var.delete_all_network != null ? null : var.delete_evs
  delete_obs                       = var.delete_all_storage != null || var.delete_all_network != null ? null : var.delete_obs
  delete_efs                       = var.delete_all_storage != null || var.delete_all_network != null ? null : var.delete_efs
  delete_sfs                       = var.delete_all_storage != null || var.delete_all_network != null ? null : var.delete_sfs
  delete_eni                       = var.delete_all_storage != null || var.delete_all_network != null ? null : var.delete_eni
  delete_net                       = var.delete_all_storage != null || var.delete_all_network != null ? null : var.delete_net
  delete_all_storage               = var.delete_all_storage
  delete_all_network               = var.delete_all_network

  dynamic "authenticating_proxy" {
    for_each = var.authenticating_proxy != null ? var.authenticating_proxy : []

    content {
      ca          = authenticating_proxy.value.ca
      cert        = authenticating_proxy.value.cert
      private_key = authenticating_proxy.value.private_key
    }
  }

  dynamic "masters" {
    for_each = var.masters != null ? var.masters : []

    content {
      availability_zone = masters.value.availability_zone
    }
  }

  dynamic "component_configurations" {
    for_each = var.component_configurations != null ? var.component_configurations : {}

    content {
      name = component_configurations.value.name

      dynamic "configurations" {
        for_each = component_configurations.value.configurations != null ? component_configurations.value.configurations : []

        content {
          name  = configurations.value.name
          value = configurations.value.value
        }
      }
    }
  }
}
