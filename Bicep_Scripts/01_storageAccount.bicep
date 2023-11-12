resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'newstorage123987'
  location: 'North Europe'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
