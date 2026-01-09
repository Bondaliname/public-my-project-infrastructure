resource "null_resource" "get_aks_credentials" {
  depends_on = [module.aks]

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ~/.kube
      az aks get-credentials \
        --resource-group ${azurerm_resource_group.rg.name} \
        --name ${module.aks.aks_name} \
        --file ~/.kube/config \
        --overwrite-existing
    EOT
  }
}
