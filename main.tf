resource "random_string" "password" {
  length      = 16
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

# Resource Group where all resources will be created
resource "azurerm_resource_group" "demo" {
  name     = "demo-resources"
  location = var.location
}

# Virtual Network (VNet) that will contain the subnet for the VM
resource "azurerm_virtual_network" "vnet" {
  name                = "demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
}

# Subnet 
resource "azurerm_subnet" "subnet" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "demo-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NI to connect the VM 
resource "azurerm_network_interface" "ni_linux" {
  name                = "demo-nic-linux"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate the NI with the NSG
resource "azurerm_network_interface_security_group_association" "ni_nsg_association" {
  network_interface_id      = azurerm_network_interface.ni_linux.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Linux Virtual Machine configuration
resource "azurerm_linux_virtual_machine" "linux_machine" {
  name                            = "demo-linux"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.demo.name
  network_interface_ids           = [azurerm_network_interface.ni_linux.id]
  size                            = "Standard_F2"
  admin_username                  = "demo-linux"
  admin_password                  = random_string.password.result
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Use Ubuntu 18.04 as the operating system
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    
    environment = var.environment
  }
}

