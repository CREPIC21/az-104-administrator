/*

Dcumentation:

1. azurerm_storage_account - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account.html

2. azurerm_storage_container - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container

3. azurerm_storage_blob - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob

4. azurerm_virtual_machine_extension - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension

*/

# Creating an storage account where we will upload custom script
resource "azurerm_storage_account" "appgrpstorage" {
  name                     = "port456243"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = azurerm_resource_group.appgrp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  depends_on = [
    azurerm_resource_group.appgrp
  ]
}

# Creating a container in storage account where we will upload custom script
resource "azurerm_storage_container" "deployment_files" {
  name                  = "deployment-files"
  storage_account_name  = azurerm_storage_account.appgrpstorage.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.appgrpstorage
  ]
}

# Creating a blob in a container where we will upload custom script
resource "azurerm_storage_blob" "files" {
  for_each = {
    "IIS_Config.ps1"   = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\02_LoadBalancer_WindowsVMs_Deployment\\IIS_Config.ps1"
    "deployScript.ps1" = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\02_LoadBalancer_WindowsVMs_Deployment\\deployScript.ps1"
    "run_scripts.ps1"  = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\02_LoadBalancer_WindowsVMs_Deployment\\run_scripts.ps1"
    "index.html"       = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\index.html"
    "style.css"        = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\style.css"
    "script.js"        = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\script.js"
    "back-photo-3.jpg" = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\back-photo-3.jpg"
    "cisco.png"        = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\cisco.png"
    "css-again.png"    = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\css-again.png"
    "html-new.png"     = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\html-new.png"
    "js-new.png"       = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\js-new.png"
    "new-tool.png"     = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\new-tool.png"
    "photoshop.png"    = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\photoshop.png"
    "python.png"       = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\python.png"
    "tool-2.png"       = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\tool-2.png"
    "tool-icon.png"    = "C:\\Users\\crepi\\Desktop\\AZ-104\\AZ_104_Administrator\\06_Azure_IaC_Project_StaticWebsite\\website\\images\\tool-icon.png"
  }
  name                   = each.key
  storage_account_name   = azurerm_storage_account.appgrpstorage.name
  storage_container_name = azurerm_storage_container.deployment_files.name
  type                   = "Block"
  source                 = each.value
  depends_on = [
    azurerm_storage_container.deployment_files
  ]
}

resource "azurerm_virtual_machine_extension" "vmextention" {
  count                = var.number_of_machines
  name                 = "vmextention"
  virtual_machine_id   = azurerm_windows_virtual_machine.appvm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "fileUris": [
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/IIS_Config.ps1", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/index.html", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/style.css", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/script.js", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/run_scripts.ps1", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/deployScript.ps1",
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/back-photo-3.jpg", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/cisco.png", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/css-again.png", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/html-new.png", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/js-new.png", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/new-tool.png",
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/photoshop.png", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/python.png",
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/tool-2.png", 
      "https://${azurerm_storage_account.appgrpstorage.name}.blob.core.windows.net/deployment-files/tool-icon.png"
      ],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file run_scripts.ps1"   
    }
SETTINGS
}


