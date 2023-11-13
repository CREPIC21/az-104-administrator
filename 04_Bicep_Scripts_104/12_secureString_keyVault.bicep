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
    ]
  }
}

// We created a keyvault manually in Azure UI, we are refferencig to it here
resource bicepvault635129 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'bicepvault635129'
  scope: resourceGroup('<subscription_id>', 'bicep')
}

// we are executing 12_vm.bicep and assigning adminpassword to VM from keyvault secret
// - meaning we just have to deploy current filr 12_secureString_keyVault.bicep and it will execute VM deployment
module vm './12_vm.bicep' = {
  name: 'deployVM'
  params: {
    adminPassword: bicepvault635129.getSecret('vmpassword')
  }
}
