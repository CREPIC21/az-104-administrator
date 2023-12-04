# Define Resource Group and Location details
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"

# Create a new Route Table without BGP route propagation
$RouteTable = New-AzRouteTable -Name "FirewallRouteTable" -ResourceGroupName $ResourceGroupName `
    -Location $Location -DisableBgpRoutePropagation

# Retrieve Firewall details
$FirewallName = "app-firewall"
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName
$FirewallPrivateIPAddress = $Firewall.IpConfigurations[0].PrivateIPAddress

# Add a route to the Route Table to route traffic through the Firewall
Add-AzRouteConfig -Name "FirewallRoute" -RouteTable $RouteTable `
    -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" `
    -NextHopIpAddress $FirewallPrivateIPAddress | Set-AzRouteTable

# Define Virtual Network and Subnet details
$VirtualNetworkName = "app-network"
$ResourceGroupName = "powershell-grp"
$SubnetName = "SubnetA"
$SubnetAddressSpace = "10.0.0.0/24"

# Retrieve the Virtual Network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Update the Subnet configuration to associate the Route Table
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $VirtualNetwork -Name $SubnetName `
    -AddressPrefix $SubnetAddressSpace -RouteTable $RouteTable | Set-AzVirtualNetwork
