using '../02_cdnProfile&Endpoint.bicep'

param profileName = 'danmanprofile'
param endpointName = 'testendpoint'
param originUrl = 'newstorage00123987.z16.web.core.windows.net'
param CDNSku = 'Standard_Microsoft'
param location = 'North Europe'
