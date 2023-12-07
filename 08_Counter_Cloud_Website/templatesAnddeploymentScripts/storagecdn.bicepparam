using 'storagecdn.bicep'

param location = 'North Europe'
param storageAccountName = 'sgdanmansw012'
param storageAccountType = 'Standard_LRS'
param storageAccountKind = 'StorageV2'
param profileName = 'swprofile012'
param sku = { value: {
    name: 'Standard_Microsoft'
  } }
