resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: 'AV-SET01'
  location: 'North Europe'
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 3
    platformUpdateDomainCount: 5
  }
}
