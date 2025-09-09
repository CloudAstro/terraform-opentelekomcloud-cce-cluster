resource "opentelekomcloud_cce_addon_v3" "this" {
  for_each         = var.addons != null ? { for key, value in var.addons : key => value } : {}
  template_name    = each.value.template_name
  template_version = each.value.template_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.cluster.id
  dynamic "values" {
    for_each = each.value.values != null ? { this = each.value.values } : {}
    content {
      basic  = values.value.basic
      custom = merge({ cluster_id = opentelekomcloud_cce_cluster_v3.cluster.id }, values.value.custom)
      flavor = values.value.flavor
    }

  }
}
