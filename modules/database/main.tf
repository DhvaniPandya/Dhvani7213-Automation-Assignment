resource "azurerm_postgresql_server" "DB_server" {
  name                = var.db_server_name
  location            = var.location
  resource_group_name = var.rg_name
  sku_name = "B_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  administrator_login          = "dbadmin19"
  administrator_login_password = "Password1#"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
  tags = var.tags
}

resource "azurerm_postgresql_database" "DB-postgre" {
  name                = var.db_name
  resource_group_name = var.rg_name
  server_name         = var.db_server_name
  charset             = "UTF8"
  collation           = "English_United States.1252"
  depends_on          = [azurerm_postgresql_server.DB_server]
}

