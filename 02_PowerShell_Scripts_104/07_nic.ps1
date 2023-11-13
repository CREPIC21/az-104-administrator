# Define the geographic location
$location = "North Europe"

# Define the name of the Azure Resource Group
$resourceGroupName = "dan-grp"

# Define the name of the Azure Virtual Network
$networkName = "dan-network"

# Define the name of the subnet within the virtual network
$subnetName = "dan-subnet"

# Define the name of the Azure Network Interface
$networkInterfaceName = "dan-interface"

# Use Get-AzVirtualNetwork to retrieve information about an existing virtual network
$virtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

# Use Get-AzVirtualNetworkSubnetConfig to retrieve subnet configuration within the virtual network
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $virtualNetwork -Name $subnetName

# Use New-AzNetworkInterface to create a new Azure Network Interface
New-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet.Id -IpConfigurationName "IpConfig"
