# Define the resource group name
$resourceGroupName = "dan-grp"

# Define the location for the resource group (in this case, "North Europe")
$location = "North Europe"

# Define the name for the virtual network
$networkName = "dan-network"

# Define the address prefix for the virtual network
$addressPrefix = "10.0.0.0/16"

# Create a new Azure Virtual Network with the specified name, resource group, location, and address prefix
New-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $addressPrefix
