targetScope = 'subscription'

resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = [for i in range(0, 2): {
  name: '0${i}test-grp'
  location: 'North Europe'
}]
