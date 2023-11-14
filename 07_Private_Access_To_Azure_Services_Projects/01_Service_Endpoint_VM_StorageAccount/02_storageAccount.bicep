resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [for i in range(0, 2): {
  name: '0${i}newstorage12349876'
  location: 'North Europe'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}]
