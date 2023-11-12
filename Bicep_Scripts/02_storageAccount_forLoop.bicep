resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [for i in range(9, 3): {
  name: '${i}newstorage12349876'
  location: 'North Europe'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}]
