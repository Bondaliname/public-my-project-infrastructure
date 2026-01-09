# Azure Authentication
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

# Resource Group
variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

# AKS Cluster
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "prefix" {
  description = "Prefix used for naming Azure resources"
  type        = string
}

variable "agents_count" {
  description = "Number of nodes in the default AKS node pool"
  type        = number
}

variable "agents_size" {
  description = "VM size for AKS nodes"
  type        = string
}

# Azure Container Registry (ACR)
variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
}

variable "acr_sku" {
  description = "ACR SKU"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

# MySQL Flexible Server
variable "mysql_server_name" {
  description = "Name of the MySQL Flexible Server"
  type        = string
}

variable "mysql_admin_username" {
  description = "Admin username for MySQL Flexible Server"
  type        = string
}

variable "mysql_admin_password" {
  description = "Admin password for MySQL Flexible Server"
  type        = string
  sensitive   = true
}

variable "mysql_sku_name" {
  description = "MySQL SKU name"
  type        = string
}

variable "mysql_storage_gb" {
  description = "Storage size for MySQL Flexible Server"
  type        = number
}

variable "mysql_database_name" {
  description = "Name of the MySQL database to create"
  type        = string
}

# Grafana
variable "grafana_admin_password" {
  description = "Administrator password for Grafana"
  type        = string
  sensitive   = true
}
