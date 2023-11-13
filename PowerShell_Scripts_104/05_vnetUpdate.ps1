# Define the resource group name
$resourceGroupName = "dan-grp"

# Define the virtual network name
$networkName = "dan-network"

# Define the name of the new subnet to be added
$subnetName = "dan-subnet"

# Define the address prefix for the new subnet
$subnetAddressPrefix = "10.0.1.0/24"  # You can set the desired subnet address prefix

# Get an existing virtual network by name and resource group
$virtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

# Display the name of the virtual network
Write-Host "Virtual Network Name: $($virtualNetwork.Name)"

# Add a subnet configuration to the virtual network
Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $virtualNetwork -AddressPrefix $subnetAddressPrefix

# Update the virtual network with the new subnet configuration
$virtualNetwork | Set-AzVirtualNetwork
