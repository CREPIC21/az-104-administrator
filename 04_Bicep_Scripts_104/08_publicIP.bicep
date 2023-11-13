resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'app-ip'
  location: 'North Europe'
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
