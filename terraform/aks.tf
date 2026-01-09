module "aks" {
  source  = "Azure/aks/azurerm"
  version = "11.0.0"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  cluster_name        = var.cluster_name
  prefix              = var.prefix

  network_plugin = "azure"

  agents_size  = var.agents_size
  agents_count = var.agents_count

  attached_acr_id_map = {
    acr = azurerm_container_registry.acr.id
  }

  temporary_name_for_rotation = "temp"
  vnet_subnet                 = azurerm_subnet.aks_subnet

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_container_registry.acr,
  ]
}
