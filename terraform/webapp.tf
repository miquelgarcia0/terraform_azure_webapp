#Web App
resource "azurerm_service_plan" "tf_sp01" {
  name                = "projectsp001"
  resource_group_name = azurerm_resource_group.projectrsg001.name
  location            = azurerm_resource_group.projectrsg001.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "example" {
  name                = "projectwa001"
  resource_group_name = azurerm_resource_group.projectrsg001.name
  location            = azurerm_service_plan.projectsp001.location
  service_plan_id     = azurerm_service_plan.tf_sp01.id
  depends_on = [ azurerm_storage_account.tf_sa01,
                 azurerm_storage_blob.tf_blob01 ]
  lifecycle {
    create_before_destroy = true
  }
  site_config {
    app_command_line = "script.sh"
  }
}

#NSG
resource "azurerm_network_security_group" "tf_nsg01" {
  name                = "projectnsg001"
  location            = azurerm_resource_group.projectrsg001.location
  resource_group_name = azurerm_resource_group.projectrsg001.name

  # Allow inbound SSH (port 22)
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "192.168.X.X" #Here you can input your IP for more security
    destination_address_prefix = "*"
  }

  # Allow inbound HTTP for web app (port 3000)
  security_rule {
    name                       = "allow_http_3000"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound traffic to the internet (all ports/protocols)
  security_rule {
    name                       = "allow_outbound_internet"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

output "webapp_pip"{
  value = "" #Your webapp .public_ip
}
