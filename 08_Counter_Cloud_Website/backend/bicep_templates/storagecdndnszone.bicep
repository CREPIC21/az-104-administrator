@allowed([
  'North Europe'
  'UK South'
])
param location string = 'North Europe'
param storageAccountName string = 'sgdanmansw012'
param storageAccountType string = 'Standard_LRS'
param storageAccountKind string = 'StorageV2'
param profileName string = 'swprofile01'
param sku object = {
  name: 'Standard_Microsoft'
}
param dnszone_name string = 'mycloudproject.online'
param hostingPlanName string = 'danmanhostingplan'
param functionappname string = 'danfuncapp'
param dbConnectionString string = 'test'

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

resource dnszone_name_resource 'Microsoft.Network/dnszones@2018-05-01' = {
  name: dnszone_name
  location: 'global'
  properties: {
    zoneType: 'Public'
  }
}

resource dnszone_name_resume 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  parent: dnszone_name_resource
  name: 'resume'
  properties: {
    TTL: 60
    CNAMERecord: {
      cname: '${storageAccountName}.azureedge.net'
    }
    targetResource: {}
  }
  dependsOn: [
    storageAccount
  ]
}

resource profile 'microsoft.cdn/profiles@2023-05-01' = {
  name: profileName
  location: location
  sku: sku
}

resource profileName_storageAccount 'microsoft.cdn/profiles/endpoints@2023-05-01' = {
  parent: profile
  name: 'storageAccountName'
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

resource profileName_storageAccountName_resume_mycloudproject_online 'Microsoft.Cdn/profiles/endpoints/customDomains@2022-11-01-preview' = {
  parent: profileName_storageAccount
  name: 'resume-mycloudproject-online'
  properties: {
    hostName: 'resume.mycloudproject.online'
  }
  dependsOn: [

    dnszone_name_resume
  ]
}

resource functionappname_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: functionappname
  kind: 'functionapp'
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'DBCONNECTIONSTRING'
          value: dbConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2022-09-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2022-09-01').keys[0].value}'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
          'https://${storageAccountName}.z16.web.core.windows.net'
          'https://${storageAccountName}.azureedge.net'
          'https://resume.${dnszone_name}'
        ]
      }
    }
    publicNetworkAccess: 'Enabled'
    httpsOnly: true
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
  }
  properties: {}
}
