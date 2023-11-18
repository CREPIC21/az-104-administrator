# Define the geographic location
$location = "North Europe"

# Define the name of the Azure Resource Group
$resourceGroupName = "powershell-grp"

# Define the name of the Azure Public IP address
$publicIpName = "dan-ip"

# Use New-AzPublicIpAddress to create a new Azure Public IP address
$PublicIPAddress = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod "Static" -Sku "standard"

$networkInterfaceName = "dan-interface"
# Retrieve Network Interface
$networkInterface = Get-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $resourceGroupName

# Retrieve the IP configuration for the Network Interface
$IpConfig = Get-AzNetworkInterfaceIpConfig -NetworkInterface $networkInterface

# Attach the Public IP address to the Network Interface
$networkInterface | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddress -Name $IpConfig.Name

# Apply the changes to the Network Interface
$networkInterface | Set-AzNetworkInterface
