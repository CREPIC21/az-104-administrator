# Define variables for the Azure environment
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$VirtualNetworkName = "app-network"
$VirtualNetworkAddressSpace = "10.0.0.0/16"
$SubnetName = "SubnetA"
$SubnetAddressSpace = "10.0.0.0/24"

# Create a subnet configuration for the virtual network
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

# Create a new Virtual Network with the defined configurations
New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
    -Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet
