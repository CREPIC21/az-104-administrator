# Define the resource group name
$resourceGroupName = "dan-grp"

# Define the name of the virtual network
$networkName = "dan-network"

# Use the Get-AzVirtualNetwork cmdlet to retrieve information about an existing virtual network
$virtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

# Display the address prefixes of the virtual network using Write-Host
Write-Host $virtualNetwork.AddressSpace.AddressPrefixes

# Display the geographic location of the virtual network using Write-Host
Write-Host $virtualNetwork.Location
