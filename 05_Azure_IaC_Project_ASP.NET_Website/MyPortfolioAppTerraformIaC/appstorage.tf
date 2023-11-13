module "app_storage_module" {
  source                 = "./modules/storage"
  resource_group_name    = var.resource_group_name
  location               = var.location
  storage_account_exists = true
  blobs_binary_enabled   = true
  storage_account_name   = var.storage_account_name
  container_name         = "images"
  container_access       = "blob"
  blobs_binary = {
    "Css.jpg"  = "./images/"
    "Html.jpg" = "./images/"
    "Js.jpg"   = "./images/"
  }
  depends_on = [
    module.general_module,
    module.storage_module
  ]
}
