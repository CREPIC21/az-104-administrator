resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'webplan7459209'
  location: 'North Europe'
  sku: {
    name: 'F1'
    capacity: 1
  }
  properties: {}
}

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: 'danapp745282635'
  location: 'North Europe'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      netFrameworkVersion: 'v6.0'
    }
  }
}
