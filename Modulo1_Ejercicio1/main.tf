# Creación de virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "lab-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = var.resource_group_name
}

# Creación de subnet
resource "azurerm_subnet" "subnet" {
    name                 = "lab-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Creación de máquina virtual
## Creación de public ip
resource "azurerm_public_ip" "public_ip" {
    name                = "lab-public-ip"
    location            = var.location
    resource_group_name = var.resource_group_name
    allocation_method   = "Static"
    sku                 = "Standard"
}

## Creación de network interface
resource "azurerm_network_interface" "nic" {
    name                = "lab-nic"
    location            = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public_ip.id
    }
}

## Creación de máquina virtual
resource "azurerm_linux_virtual_machine" "vm" {
    name                            = "lab-vm"
    resource_group_name             = var.resource_group_name
    location                        = var.location
    size                            = "Standard_D2s_v3"
    disable_password_authentication = false
    admin_username                  = var.admin_username
    admin_password                  = var.admin_password
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
}