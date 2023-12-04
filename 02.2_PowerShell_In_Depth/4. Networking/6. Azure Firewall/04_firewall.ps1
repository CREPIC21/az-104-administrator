# Define Azure resource details
$VirtualNetworkName = "app-network"
$ResourceGroupName = "powershell-grp"
$FirewallSubnetName = "AzureFirewallSubnet"
$FirewallSubnetAddressSpace = "10.0.1.0/24"

# Retrieve the existing virtual network details
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Add a subnet configuration for the Azure Firewall
Add-AzVirtualNetworkSubnetConfig -Name $FirewallSubnetName `
    -VirtualNetwork $VirtualNetwork -AddressPrefix $FirewallSubnetAddressSpace

# Update the virtual network with the new subnet
$VirtualNetwork | Set-AzVirtualNetwork

# Define public IP details for the Azure Firewall
$PublicIPDetails = @{
    Name              = 'firewall-ip'
    Location          = $Location
    Sku               = 'Standard'
    AllocationMethod  = 'Static'
    ResourceGroupName = $ResourceGroupName
}

# Create a public IP for the Azure Firewall
$FirewallPublicIP = New-AzPublicIpAddress @PublicIPDetails

# Define Azure Firewall and policy details
$FirewallName = "app-firewall"
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$VirtualNetworkName = "app-network"

# Retrieve the virtual network details for the Azure Firewall
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Define a firewall policy for the Azure Firewall
$FirewallPolicyName = "firewall-policy"
$FirewallPolicy = New-AzFirewallPolicy -Name $FirewallPolicyName -ResourceGroupName $ResourceGroupName `
    -Location $Location

# Retrieve the created public IP for the Azure Firewall
$FirewallPublicIP = Get-AzPublicIpAddress -Name $PublicIPDetails.Name

# Create the Azure Firewall and associate it with the defined resources
$AzureFirewall = New-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName `
    -Location $Location -VirtualNetwork $VirtualNetwork -PublicIpAddress $FirewallPublicIP `
    -FirewallPolicyId $FirewallPolicy.Id
