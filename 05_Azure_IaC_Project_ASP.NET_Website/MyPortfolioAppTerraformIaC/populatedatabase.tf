module "storage_module" {
  source               = "./modules/storage"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_name = var.storage_account_name
  container_name       = "scripts"
  app_container_name   = "images"
  blobs_enabled        = true
  container_access     = "blob"
  blobs = {
    "01.sql"     = "./dbscripts/"
    "Script.ps1" = "./scripts/"
  }
  depends_on = [
    module.general_module
  ]
}

module "custom_script" {
  source             = "./modules/compute/customscript"
  extension_name     = "dbvm-extension"
  virtual_machine_id = module.compute_module.vm.id
  extension_type = {
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
  }
  storage_account_name = var.storage_account_name
  container_name       = "scripts"
  SQL_USERNAME         = var.SQL_USERNAME
  SQL_PASSWORD         = var.SQL_PASSWORD

  depends_on = [
    module.compute_module,
    module.storage_module,
    azurerm_mssql_virtual_machine.mssqlmachine
  ]
}
