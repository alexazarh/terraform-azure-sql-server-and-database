terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "sandbox_rg" {
  name = var.SANDBOX_ID
}

resource "random_password" "db_password" { 
  length = 16
  special = true
  override_special = "_%@"
  min_special = 1
  min_lower = 1
  min_upper = 1
  min_numeric = 1
}


resource "azurerm_sql_server" "default" {
  name                = "${var.SANDBOX_ID}-${lower(var.DB_NAME)}-sqlsvr"
  resource_group_name = data.azurerm_resource_group.sandbox_rg.name
  location            = data.azurerm_resource_group.sandbox_rg.location
  version                      = "12.0"
  administrator_login          = var.DB_USERNAME
  administrator_login_password = random_password.db_password.result
}

resource "azurerm_sql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = data.azurerm_resource_group.sandbox_rg.name
  server_name         = azurerm_sql_server.default.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_firewall_rule" "allow_additional_ip" {
  name                = "AllowAdditionalIP"
  resource_group_name = data.azurerm_resource_group.sandbox_rg.name
  server_name         = azurerm_sql_server.default.name
  start_ip_address    = var.ALLOW_IP_IN_FIREWALL
  end_ip_address      = var.ALLOW_IP_IN_FIREWALL
}

resource "azurerm_sql_firewall_rule" "allow_additional_ip3" {
  name                = "AllowAdditionalIP3"
  resource_group_name = data.azurerm_resource_group.sandbox_rg.name
  server_name         = azurerm_sql_server.default.name
  start_ip_address    = "10.10.10.100"
  end_ip_address      = "10.10.10.100"
}

resource "azurerm_sql_database" "default" {
  name                = var.DB_NAME
  resource_group_name = data.azurerm_resource_group.sandbox_rg.name
  location            = data.azurerm_resource_group.sandbox_rg.location
  server_name         = azurerm_sql_server.default.name
  edition             = "Standard"
  create_mode         = "Default"
}
