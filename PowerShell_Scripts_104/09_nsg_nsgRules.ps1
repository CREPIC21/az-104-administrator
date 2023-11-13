# Define the geographic location
$location = "North Europe"

# Define the name of the Azure Resource Group
$resourceGroupName = "dan-grp"

# Define the name of the Azure Network Security Group
$networkSecurityGroupName = "dan-grp"

# Create a network security rule for allowing RDP traffic
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix 10.0.0.0/24 -DestinationPortRange 3389

# Create a network security rule for allowing HTTP traffic
$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 130 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix 10.0.0.0/24 -DestinationPortRange 80

# Use New-AzNetworkSecurityGroup to create a new Azure Network Security Group with the specified security rules
New-AzNetworkSecurityGroup -Name $networkSecurityGroupName -ResourceGroupName $resourceGroupName -Location $location -SecurityRules $nsgRule1, $nsgRule2
