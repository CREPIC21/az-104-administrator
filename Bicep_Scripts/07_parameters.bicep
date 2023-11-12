// @description('Please specify a location') //currently there is a bug: ttps://github.com/MicrosoftDocs/azure-docs/issues/113981
// param location string

var networkName = 'app-network'
var networkAddressPrefix = '10.0.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: networkName
  location: 'North Europe'
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkAddressPrefix
      ]
    }
    subnets: [for i in range(1, 3): {

      name: 'SubnetA${i}'
      properties: {
        addressPrefix: cidrSubnet('10.0.0.0/16', 24, i)
      }
    }
    ]
  }
}
