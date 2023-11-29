# Define Azure Resource Group and location
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"

# Define Virtual Network details
$VirtualNetworkName = "app-network"
$VirtualNetworkAddressSpace = "10.0.0.0/16"
$SubnetName = "SubnetA"
$SubnetAddressSpace = "10.0.0.0/24"

# Create Subnet Configuration
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

# Create Virtual Network with defined parameters
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
    -Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet
