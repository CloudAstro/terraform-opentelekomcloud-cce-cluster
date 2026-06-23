resource "opentelekomcloud_cce_node_v3" "this" {
  for_each = var.nodes != null ? var.nodes : {}

  cluster_id                 = opentelekomcloud_cce_cluster_v3.cluster.id
  flavor_id                  = each.value.flavor_id
  availability_zone          = each.value.availability_zone
  key_pair                   = each.value.key_pair
  os                         = each.value.os
  name                       = each.value.name
  subnet_id                  = each.value.subnet_id
  labels                     = each.value.labels
  tags                       = each.value.tags
  k8s_tags                   = each.value.k8s_tags
  annotations                = each.value.annotations
  runtime                    = each.value.runtime
  agency_name                = each.value.agency_name
  eip_ids                    = each.value.eip_ids
  eip_count                  = each.value.eip_count
  iptype                     = each.value.iptype
  bandwidth_size             = each.value.bandwidth_size
  bandwidth_charge_mode      = each.value.bandwidth_charge_mode
  sharetype                  = each.value.sharetype
  extend_param_charging_mode = each.value.extend_param_charging_mode
  dedicated_host_id          = each.value.dedicated_host_id
  ecs_performance_type       = each.value.ecs_performance_type
  order_id                   = each.value.order_id
  product_id                 = each.value.product_id
  max_pods                   = each.value.max_pods
  public_key                 = each.value.public_key
  private_ip                 = each.value.private_ip
  preinstall                 = each.value.preinstall
  postinstall                = each.value.postinstall
  docker_base_size           = each.value.docker_base_size
  docker_lvm_config_override = each.value.docker_lvm_config_override

  dynamic "taints" {
    for_each = each.value.taints != null ? each.value.taints : []

    content {
      key    = taints.value.key
      value  = taints.value.value
      effect = taints.value.effect
    }
  }

  root_volume {
    size          = each.value.root_volume.size
    volumetype    = each.value.root_volume.volumetype
    extend_params = each.value.root_volume.extend_params
    kms_id        = each.value.root_volume.kms_id
  }

  dynamic "data_volumes" {
    for_each = each.value.data_volumes

    content {
      size          = data_volumes.value.size
      volumetype    = data_volumes.value.volumetype
      extend_params = data_volumes.value.extend_params
      kms_id        = data_volumes.value.kms_id
    }
  }

  lifecycle {
    ignore_changes = [
      k8s_tags["cce.cloud.com/cce-nodepool-id"],
      billing_mode,
      region,
      tags,
    ]
  }
}
