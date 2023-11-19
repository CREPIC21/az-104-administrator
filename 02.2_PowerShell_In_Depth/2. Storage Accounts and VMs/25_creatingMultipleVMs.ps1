# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the Azure Virtual Network name
$networkName = "app-network"

# Define the geographic location
$location = "North Europe"

# Define the address prefix for the virtual network
$AddressPrefix = "10.0.0.0/16"

# Define the name and address prefix for the subnet
$subnetName = "SubnetA"
$subnetAddressPrefix = "10.0.0.0/24"

# Create a subnet configuration
$subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix

# Create a new Azure Virtual Network with the specified parameters
New-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroup `
    -Location $location -AddressPrefix $AddressPrefix -Subnet $subnet

# Retrieve information about the Virtual Network
$VirtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroup

# Retrieve subnet information from the Virtual Network
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VirtualNetwork -Name $subnetName

# Define the name for the Network Interface
$networkInterfaceName = "app-interface"
$networkInterfaceArray = @()

# Create network interfaces
for ($i = 1; $i -le 2; $i++) {
    $networkInterfaceArray += New-AzNetworkInterface -Name "$networkInterfaceName$i" -ResourceGroupName $resourceGroup -Location $location `
        -SubnetId $subnet.Id -IpConfigurationName "IpConfig"
}

# Define the name for the Public IP address
$publicIPAddress = "app-ip"
$publicIPAddressArray = @()
$ipConfigArray = @()

# Create a new Azure Public IP addresses and attac them to the network interfaces
for ($i = 1; $i -le 2; $i++) {
    $publicIPAddressArray += New-AzPublicIpAddress -Name "$publicIPAddress$i" -ResourceGroupName $resourceGroup `
        -Location $location -Sku "Standard" -AllocationMethod "Static"

    # Retrieve the IP configuration for the Network Interface
    $ipConfigArray += Get-AzNetworkInterfaceIpConfig -NetworkInterface $networkInterfaceArray[$i - 1]

    # Attach the Public IP address to the Network Interface
    $networkInterfaceArray[$i - 1] | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $publicIPAddressArray[$i - 1] `
        -Name $ipConfigArray[$i - 1].Name

    # Apply the changes to the Network Interface
    $networkInterfaceArray[$i - 1] | Set-AzNetworkInterface
}

# Define the name for the Network Security Group
$networkSecurityGroupName = "app-nsg"

# Define Network Security Group rules
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Access Allow -Protocol Tcp `
    -Direction Inbound -Priority 120 -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix 10.0.0.0/24 -DestinationPortRange 3389

$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Access Allow -Protocol Tcp `
    -Direction Inbound -Priority 130 -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix 10.0.0.0/24 -DestinationPortRange 80

# Create a new Azure Network Security Group with the specified rules
$networkSecurityGroup = New-AzNetworkSecurityGroup -Name $networkSecurityGroupName -ResourceGroupName $resourceGroup `
    -Location $location -SecurityRules $nsgRule1, $nsgRule2

# Attach the NSG to the subnet
Set-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $VirtualNetwork `
    -NetworkSecurityGroup $networkSecurityGroup -AddressPrefix $subnetAddressPrefix

# Apply the changes to the Virtual Network
$VirtualNetwork | Set-AzVirtualNetwork

# Define the name for the Virtual Machine
$vmName = "appvm"

# Define the size of the Virtual Machine
$VMSize = "Standard_DS2_v2"

# Get the user credentials for the Virtual Machine
$Credential = Get-Credential

$vmConfig = @()
$Vm = @()
for ($i = 1; $i -le 2; $i++) {
    # Create a new Azure VM configuration
    $vmConfig += New-AzVMConfig -Name "$vmName$i" -VMSize $VMSize

    # Set the operating system for the Virtual Machine to Windows using the specified credentials
    Set-AzVMOperatingSystem -VM $vmConfig[$i - 1] -ComputerName "$vmName$i" -Credential $Credential -Windows

    # Set the source image for the Virtual Machine to Windows Server 2022 Datacenter
    Set-AzVMSourceImage -VM $vmConfig[$i - 1] -PublisherName "MicrosoftWindowsServer" `
        -Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest"

    # Retrieve information about the Network Interface
    $networkInterfaceArray[$i - 1] = Get-AzNetworkInterface -Name "$networkInterfaceName$i" -ResourceGroupName $resourceGroup

    # Add the Network Interface to the Virtual Machine configuration
    $Vm += Add-AzVMNetworkInterface -VM $vmConfig[$i - 1] -Id $networkInterfaceArray[$i - 1].Id

    # Disable boot diagnostics for the Virtual Machine
    Set-AzVMBootDiagnostic -Disable -VM $Vm[$i - 1]

    # Create a new Azure Virtual Machine in the specified resource group and location
    New-AzVM -ResourceGroupName $resourceGroup -Location $Location -VM $Vm[$i - 1]
}
