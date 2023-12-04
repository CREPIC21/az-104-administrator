# Define variables for the Azure environment
$VirtualNetworkName = "app-network"
$ResourceGroupName = "powershell-grp"
$AppGatewaySubnetName = "AppGatewaySubnet"
$AppGatewaySubnetAddressSpace = "10.0.1.0/24"

# Retrieve the existing virtual network by name
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Add a subnet configuration for the application gateway
Add-AzVirtualNetworkSubnetConfig -Name $AppGatewaySubnetName `
    -VirtualNetwork $virtualNetwork -AddressPrefix $AppGatewaySubnetAddressSpace

# Apply changes to the virtual network
$virtualNetwork | Set-AzVirtualNetwork

# Define details for the public IP of the application gateway
$PublicIPDetails = @{
    Name              = 'gateway-ip'
    Location          = $Location
    Sku               = 'Standard'
    AllocationMethod  = 'Static'
    ResourceGroupName = $ResourceGroupName
}

# Create a new public IP address for the application gateway
$PublicIP = New-AzPublicIpAddress @PublicIPDetails

# Retrieve the updated virtual network details after the subnet addition
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Create configurations for the Application Gateway
$AppGatewayConfig = New-AzApplicationGatewayIPConfiguration -Name "AppGatewayConfig" `
    -Subnet $VirtualNetwork.Subnets[1]

# Retrieve the created public IP address
$PublicIP = Get-AzPublicIpAddress -Name $PublicIPDetails.Name

# Create configurations for the frontend IP, port, backend address pools, HTTP settings, listener, and path rules
# These configurations are necessary for the Application Gateway
$ImagePathRule = New-AzApplicationGatewayPathRuleConfig -Name "ImageRule" `
    -Paths "/images/*" -BackendAddressPool $ImageBackendAddressPool -BackendHttpSettings $HTTPSetting

$VideoPathRule = New-AzApplicationGatewayPathRuleConfig -Name "VideoRule" `
    -Paths "/videos/*" -BackendAddressPool $VideoBackendAddressPool -BackendHttpSettings $HTTPSetting

$PathMapConfig = New-AzApplicationGatewayUrlPathMapConfig -Name "URLMap" `
    -PathRules $ImagePathRule, $VideoPathRule -DefaultBackendAddressPool $ImageBackendAddressPool `
    -DefaultBackendHttpSettings $HTTPSetting

# Create a routing rule for the Application Gateway
$RoutingRule = New-AzApplicationGatewayRequestRoutingRule -Name "RuleA" `
    -RuleType PathBasedRouting -HttpListener $Listener -UrlPathMap $PathMapConfig -Priority "100"

# Define the SKU for the Application Gateway
$GatewaySku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 2

# Create the Application Gateway with specified configurations
$ApplicationGateway = New-AzApplicationGateway -ResourceGroupName $ResourceGroupName `
    -Name "app-gateway" -Sku $GatewaySku -Location $Location `
    -GatewayIPConfigurations $AppGatewayConfig -FrontendIPConfigurations $AppGatewayFrontEndIPConfig `
    -FrontendPorts $AppGatewayFrontEndPort -BackendAddressPools $ImageBackendAddressPool, $VideoBackendAddressPool `
    -HttpListeners $Listener -BackendHttpSettingsCollection $HTTPSetting `
    -RequestRoutingRules $RoutingRule -UrlPathMaps $PathMapConfig
