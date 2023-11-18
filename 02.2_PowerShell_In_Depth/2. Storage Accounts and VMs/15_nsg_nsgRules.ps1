# Define the geographic location
$location = "North Europe"

# Define the name of the Azure Resource Group
$resourceGroupName = "powershell-grp"

# Define the name of the Azure Network Security Group
$networkSecurityGroupName = "dan-grp"

# Define the name of the Azure Virtual Network
$networkName = "dan-network"

# Define the name of the subnet within the virtual network
$subnetName = "dan-subnet"

# Define the address prefix for the subnet
$subnetAddressPrefix = "10.0.1.0/24"

# Create a network security rule for allowing RDP traffic
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix 10.0.0.0/24 -DestinationPortRange 3389

# Create a network security rule for allowing HTTP traffic
$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 130 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix 10.0.0.0/24 -DestinationPortRange 80

# Use New-AzNetworkSecurityGroup to create a new Azure Network Security Group with the specified security rules
$networkSecurityGroup = New-AzNetworkSecurityGroup -Name $networkSecurityGroupName -ResourceGroupName $resourceGroupName -Location $location -SecurityRules $nsgRule1, $nsgRule2

# Use Get-AzVirtualNetwork to retrieve information about an existing virtual network
$virtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

# Use Get-AzVirtualNetworkSubnetConfig to retrieve subnet configuration within the virtual network
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $virtualNetwork -Name $subnetName

# Attach the NSG to the subnet
Set-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $virtualNetwork `
    -NetworkSecurityGroup $networkSecurityGroup -AddressPrefix $subnetAddressPrefix

# Apply the changes to the Virtual Network
$virtualNetwork | Set-AzVirtualNetwork
