# Define the resource group name
$resourceGroupName = "dan-grp"

# Define the location for the resource group (in this case, "North Europe")
$location = "North Europe"

# Define the name for the virtual network
$networkName = "dan-network"

# Define the address prefix for the virtual network
$addressPrefix = "10.0.0.0/16"

## Remove-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

# Use the New-AzVirtualNetwork cmdlet to create a new Azure Virtual Network
$virtualNetwork = New-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $addressPrefix

# Display the address prefixes of the virtual network using Write-Host
Write-Host $virtualNetwork.AddressSpace.AddressPrefixes

# Display the geographic location of the virtual network using Write-Host
Write-Host $virtualNetwork.Location
