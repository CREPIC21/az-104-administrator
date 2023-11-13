resource "azurerm_network_interface" "webinterface" {
  name                = "webinterface"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking_module.subnets["web-subnet"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webip.id
  }

  depends_on = [
    module.networking_module.virtual_network,
    azurerm_public_ip.webip,
    module.general_module
  ]
}

resource "azurerm_public_ip" "webip" {
  name                = "web-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  domain_name_label   = "testdan5467"
  allocation_method   = "Static"
  depends_on          = [module.general_module]
}

data "azurerm_shared_image" "testimage" {
  name                = "testimage"
  gallery_name        = "testgalerry"
  resource_group_name = "new-gr" // remember we created an image in different resource group directly in Azure UI
}

resource "azurerm_virtual_machine" "webvm" {
  name                  = "webvm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.webinterface.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    id = data.azurerm_shared_image.testimage.id
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  depends_on = [
    azurerm_network_interface.webinterface,
    module.general_module.resourcegroup
  ]

}


