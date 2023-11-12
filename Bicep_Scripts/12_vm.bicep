@secure()
param adminPassword string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'newstorage987123'
  location: 'North Europe'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'vm01'
  location: 'North Europe'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'vm01'
      adminUsername: 'adminuser'
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'disk01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'app-nic')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(resourceId('Microsoft.Storage/storageAccounts/', toLower('danstore82730'))).primaryEndpoints.blob
      }
    }
  }
}
