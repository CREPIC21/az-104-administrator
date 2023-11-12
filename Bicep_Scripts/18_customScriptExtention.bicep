// @description('Please specify admin password') //currently there is a bug: ttps://github.com/MicrosoftDocs/azure-docs/issues/113981
// param vmadminpassword string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'app-network'
  location: 'North Europe'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'SubnetA'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'SubnetB'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'app-ip'
  location: 'North Europe'
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'app-nic'
  location: 'North Europe'
  properties: {
    ipConfigurations: [
      {
        name: 'IPConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'app-network', 'SubnetA')
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'danstore82730'
  location: 'North Europe'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-01'
  location: 'North Europe'
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          description: 'Allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          description: 'Allow HTTP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource windowsVMExtensions 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: windowsVM
  name: 'name'
  location: 'North Europe'
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://danman64927432.blob.core.windows.net/scripts/IISS_Config.ps1?sp=r&st=2023-10-28T18:28:48Z&se=2023-10-29T02:28:48Z&spr=https&sv=2022-11-02&sr=b&sig=pEyuGraiSVA9u39WzW%2BnHE1SrZJLZng4Z3LRSNNBp%2F8%3D'
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File IISS_Config.ps1'
    }
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
      adminPassword: 'Test12345%$#@!'
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
          id: networkInterface.id
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
