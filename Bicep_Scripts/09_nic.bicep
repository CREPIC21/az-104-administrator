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
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'app-network', 'SubnetA1')
          }
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', 'app-ip')
          }
        }
      }
    ]
  }
}
