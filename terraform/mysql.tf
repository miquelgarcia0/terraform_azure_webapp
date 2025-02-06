resource "azurerm_mysql_server" "tf_mysql01" {
  name                = "miquel-mysql-server"
  location            = azurerm_resource_group.tf_rsg01.location
  resource_group_name = azurerm_resource_group.tf_rsg01.name

  administrator_login          = "root"
  administrator_login_password = "your-secure-password"
  sku_name                     = "GP_Gen5_2"  # General Purpose, 2 vCores
  storage_mb                   = 102400  # 100GB
  version                      = "5.7"
  ssl_enforcement_enabled      = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"  # Required for Entra ID authentication
  }

  tags = {
    environment = "dev"
    project     = "webapp-deployment-project"
  }
}

resource "azurerm_mysql_database" "tf_mysql_db" {
  name                = "miquel_demo"
  resource_group_name = azurerm_resource_group.tf_rsg01.name
  server_name         = azurerm_mysql_server.tf_mysql01.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_general_ci"
}

resource "azurerm_mysql_active_directory_administrator" "tf_mysql_ad" {
  server_name         = azurerm_mysql_server.tf_mysql01.name
  resource_group_name = azurerm_resource_group.tf_rsg01.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  login              = "AzureADAdmin"
}

resource "azurerm_mysql_firewall_rule" "allow_azure" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.tf_rsg01.name
  server_name         = azurerm_mysql_server.tf_mysql01.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_firewall_rule" "allow_specific_ip" {
  name                = "AllowYourIP"
  resource_group_name = azurerm_resource_group.tf_rsg01.name
  server_name         = azurerm_mysql_server.tf_mysql01.name
  start_ip_address    = "YOUR_PUBLIC_IP"
  end_ip_address      = "YOUR_PUBLIC_IP"
}
