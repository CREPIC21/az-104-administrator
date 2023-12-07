@allowed([
  'North Europe'
  'UK South'
])
param location string
param storageAccountName string
param storageAccountType string
param storageAccountKind string
param profileName string
param sku object = {
  name: 'Standard_Microsoft'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  kind: storageAccountKind
  sku: {
    name: storageAccountType
  }
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: false
  }
}

resource profile 'microsoft.cdn/profiles@2023-05-01' = {
  name: profileName
  location: location
  sku: sku
}

resource profileName_storageAccount 'microsoft.cdn/profiles/endpoints@2023-05-01' = {
  parent: profile
  name: '${storageAccountName}'
  location: location
  properties: {
    originHostHeader: '${storageAccountName}.z16.web.core.windows.net'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    origins: [
      {
        name: 'origin1'
        properties: {
          hostName: '${storageAccountName}.z16.web.core.windows.net'
        }
      }
    ]
  }
  dependsOn: [

    storageAccount
  ]
}
