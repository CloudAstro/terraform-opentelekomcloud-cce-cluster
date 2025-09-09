resource "opentelekomcloud_cce_node_pool_v3" "this" {
  for_each                   = var.node_pools != null ? var.node_pools : {}
  cluster_id                 = opentelekomcloud_cce_cluster_v3.cluster.id
  flavor                     = each.value.flavor
  availability_zone          = each.value.availability_zone
  key_pair                   = each.value.key_pair
  password                   = each.value.password
  os                         = each.value.os
  name                       = each.value.name
  initial_node_count         = each.value.initial_node_count
  subnet_id                  = each.value.subnet_id
  preinstall                 = each.value.preinstall
  postinstall                = each.value.postinstall
  max_pods                   = each.value.max_pods
  docker_base_size           = each.value.docker_base_size
  docker_lvm_config_override = each.value.docker_lvm_config_override
  scale_enable               = each.value.scale_enable
  min_node_count             = each.value.min_node_count
  max_node_count             = each.value.max_node_count
  scale_down_cooldown_time   = each.value.scale_down_cooldown_time
  server_group_reference     = each.value.server_group_reference
  security_group_ids         = each.value.security_group_ids
  priority                   = each.value.priority
  user_tags                  = each.value.user_tags
  k8s_tags                   = each.value.k8s_tags
  runtime                    = each.value.runtime
  agency_name                = each.value.agency_name
  storage                    = each.value.storage

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
}
