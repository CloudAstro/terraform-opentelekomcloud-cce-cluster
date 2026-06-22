resource "opentelekomcloud_cce_node_attach_v3" "this" {
  for_each = var.node_attach != null ? var.node_attach : {}

  cluster_id             = opentelekomcloud_cce_cluster_v3.cluster.id
  server_id              = each.value.server_id
  os                     = each.value.os
  name                   = each.value.name
  key_pair               = each.value.key_pair
  password               = each.value.password
  private_key            = each.value.private_key
  runtime                = each.value.runtime
  max_pods               = each.value.max_pods
  system_disk_kms_key_id = each.value.system_disk_kms_key_id
  docker_base_size       = each.value.docker_base_size
  lvm_config             = each.value.lvm_config
  preinstall             = each.value.preinstall
  postinstall            = each.value.postinstall
  tags                   = each.value.tags
  k8s_tags               = each.value.k8s_tags
  dynamic "taints" {
    for_each = each.value.taints != null ? each.value.taints : []
    content {
      key    = taints.value.key
      value  = taints.value.value
      effect = taints.value.effect
    }
  }

  dynamic "storage" {
    for_each = each.value.storage != null ? [each.value.storage] : []
    content {
      dynamic "selectors" {
        for_each = storage.value.selectors != null ? storage.value.selectors : []
        content {
          name                           = selectors.value.name
          type                           = selectors.value.type
          match_label_size               = selectors.value.match_label_size
          match_label_volume_type        = selectors.value.match_label_volume_type
          match_label_metadata_encrypted = selectors.value.match_label_metadata_encrypted
          match_label_metadata_cmkid     = selectors.value.match_label_metadata_cmkid
          match_label_count              = selectors.value.match_label_count
        }
      }

      dynamic "groups" {
        for_each = storage.value.groups != null ? storage.value.groups : []
        content {
          name           = groups.value.name
          cce_managed    = groups.value.cce_managed
          selector_names = groups.value.selector_names

          dynamic "virtual_spaces" {
            for_each = groups.value.virtual_spaces != null ? groups.value.virtual_spaces : []
            content {
              name            = virtual_spaces.value.name
              size            = virtual_spaces.value.size
              lvm_lv_type     = virtual_spaces.value.lvm_lv_type
              lvm_path        = virtual_spaces.value.lvm_path
              runtime_lv_type = virtual_spaces.value.runtime_lv_type
            }
          }
        }
      }
    }
  }
}
