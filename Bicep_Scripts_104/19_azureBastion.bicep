resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'bastion-network'
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
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'bastion-ip'
  location: 'North Europe'
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource symbolicname 'Microsoft.Network/bastionHosts@2023-04-01' = {
  name: 'app-bastion'
  location: 'North Europe'
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-config'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'bastion-network', 'AzureBastionSubnet')
          }
        }
      }
    ]
  }
}
