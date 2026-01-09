resource_group_name = "rg-games"
location            = "northeurope"

cluster_name = "aks-games-cluster"
prefix       = "games"
agents_count = 1
agents_size  = "Standard_B2ms"

acr_name    = "games123451854321games"
acr_sku     = "Basic"
environment = "production"

mysql_server_name    = "mysql-games"
mysql_admin_username = "mysqladmin"
mysql_sku_name       = "B_Standard_B1ms"
mysql_storage_gb     = 20
mysql_database_name  = "gamesdb"
