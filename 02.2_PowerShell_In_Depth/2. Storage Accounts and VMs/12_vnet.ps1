# Define the resource group name
$resourceGroupName = "powershell-grp"

# Define the location for the resource group (in this case, "North Europe")
$location = "North Europe"

# Define the name for the virtual network
$networkName = "dan-network"

# Define the address prefix for the virtual network
$addressPrefix = "10.0.0.0/16"

# Define the name for the subnet within the virtual network
$subnetName = "dan-subnet"

# Define the address prefix for the subnet
$subnetAddressPrefix = "10.0.1.0/24"

# Create a subnet configuration using New-AzVirtualNetworkSubnetConfig cmdlet
$subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix

# Use New-AzVirtualNetwork to create a new Azure Virtual Network with the specified subnet configuration
New-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet
