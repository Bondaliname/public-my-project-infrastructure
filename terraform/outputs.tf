# AKS Outputs
output "get_credentials" {
  description = "Command to load AKS credentials into kubeconfig"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${module.aks.aks_name}"
}

# Traefik Outputs
output "traefik_public_ip_command" {
  description = "Command to get the public IP of the Traefik LoadBalancer"
  value       = "kubectl get svc -n traefik traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
}

output "traefik_ip" {
  description = "Public IP of Traefik LoadBalancer"
  value       = data.external.traefik_ip.result.ip
}

# Azure Container Registry Outputs
output "acr_login_server" {
  description = "Azure Container Registry login server URL"
  value       = azurerm_container_registry.acr.login_server
}

# MySQL Flexible Server Outputs
output "mysql_host" {
  description = "MySQL host"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
  sensitive   = true
}

output "mysql_database" {
  description = "MySQL database name"
  value       = var.mysql_database_name
}

output "mysql_connection_string" {
  description = "MySQL connection string for application"
  value       = "mysql://${var.mysql_admin_username}@${azurerm_mysql_flexible_server.mysql.fqdn}:3306/${var.mysql_database_name}"
  sensitive   = true
}

# Networking Outputs
output "vnet_id" {
  description = "Virtual Network resource ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "AKS subnet resource ID"
  value       = azurerm_subnet.aks_subnet.id
}

# Grafana Access
output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://grafana.${data.external.traefik_ip.result["ip"]}.nip.io"
}
