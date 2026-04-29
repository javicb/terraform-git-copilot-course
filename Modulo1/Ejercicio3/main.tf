resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = "${var.project_name}-${each.key}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.cidr]
}

resource "azurerm_network_security_group" "nsg" {    
  for_each            = var.subnets
  name                = "${var.environment}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_network_security_rule" "allow_admin" {
  for_each            = var.subnets
  name                = "${var.environment}-${each.key}-allow-admin-access"
  priority            = 100
  direction           = "Inbound"
  access              = "Allow"
  protocol            = "Tcp"
  source_port_range   = "*"
  destination_port_range = "22"
  source_address_prefix   = var.allowed_admin_cidr
  destination_address_prefix = "*"
  network_security_group_name = azurerm_network_security_group.nsg[each.key].name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_http" {
  for_each            = {
    for key, value in var.subnets : key => value if value.allow_http
  }
  name                = "${var.environment}-${each.key}-allow-http-access"
  priority            = 110
  direction           = "Inbound"
  access              = "Allow"
  protocol            = "Tcp"
  source_port_range   = "*"
  destination_port_range = "80"
  source_address_prefix   = "*"
  destination_address_prefix = "*"
  network_security_group_name = azurerm_network_security_group.nsg[each.key].name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_account" "diagnostics" {
  count                    = var.create_diagnostics_storage ? 1 : 0
  name                     = "${var.environment}diagsa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "pro" ? "GRS" : "LRS"
}