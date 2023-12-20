param dbName string = 'resumecountdb01'
param vaults_resumevaultdabman_name string = 'resumedbkeyvault01'
param location string = 'North Europe'

resource db 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: dbName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    publicNetworkAccess: 'Enabled'
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'BoundedStaleness'
      maxIntervalInSeconds: 86400
      maxStalenessPrefix: 1000000
    }
    locations: [
      {
        locationName: location
      }
    ]
    capabilities: [
      {
        name: 'EnableTable'
      }
      {
        name: 'EnableServerless'
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 1440
        backupRetentionIntervalInHours: 48
        backupStorageRedundancy: 'Local'
      }
    }
    capacity: {
      totalThroughputLimit: 4000
    }
  }
}

resource vaults_resumevaultdabman_name_resource 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaults_resumevaultdabman_name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    vaultUri: 'https://${vaults_resumevaultdabman_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource vaults_resumevaultdabman_name_DBCONNECTIONSTRING 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vaults_resumevaultdabman_name_resource
  name: 'DBCONNECTIONSTRING'
  location: location
  properties: {
    value: ''
    attributes: {
      enabled: true
    }
  }
}
