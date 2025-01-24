resource "azurerm_resource_group" "tf_rsg01" {
  name     = "projectrsg001"
  location = "West Europe"

  tags = {
    environment = "dev"
    owner       = "Miquel"
    project     = "webapp-deployment-project"
  }
}

resource "azurerm_storage_account" "tf_sa01" {
  name                     = "projectsamgowa001}"
  resource_group_name      = azurerm_resource_group.tf_rsg01.name
  location                 = azurerm_resource_group.tf_rsg01.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tf_cnt01" {
  name                  = "projectcnt001"
  storage_account_id = azurerm_storage_account.tf_sa01.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tf_blob01" {
  name                   = "projectblob001"
  for_each = fileset("../public/images", "**")
  storage_account_name   = azurerm_storage_account.tf_sa01.name
  storage_container_name = azurerm_storage_container.tf_cnt01.name
  type                   = "Block"
  source                 = "../public/images"
}