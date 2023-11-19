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

# Define the name for the Public IP address
$publicIPAddress = "app-ip"

# Create a new Azure Public IP address with dynamic allocation
$publicIPAddress = New-AzPublicIpAddress -Name $publicIPAddress -ResourceGroupName $resourceGroup `
    -Location $location -AllocationMethod Dynamic

# Define the name for the Network Interface
$networkInterfaceName = "app-interface"

# Retrieve information about the Virtual Network
$VirtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroup

# Retrieve subnet information from the Virtual Network
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VirtualNetwork -Name $subnetName

# Create a new Azure Network Interface with the specified parameters
$networkInterface = New-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $resourceGroup -Location $location `
    -SubnetId $subnet.Id -IpConfigurationName "IpConfig"

# Retrieve the IP configuration for the Network Interface
$IpConfig = Get-AzNetworkInterfaceIpConfig -NetworkInterface $networkInterface

# Attach the Public IP address to the Network Interface
$networkInterface | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $publicIPAddress `
    -Name $IpConfig.Name

# Apply the changes to the Network Interface
$networkInterface | Set-AzNetworkInterface

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

# Define the name for the Availability Set
$availabilitySetName = "app-set"

# Create a new Azure Availability Set with the specified parameters
$availabilitySet = New-AzAvailabilitySet -Location $location -ResourceGroupName $resourceGroup -Name $availabilitySetName `
    -Sku aligned -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5

# Define the name for the Virtual Machine
$vmName = "appvm"

# Define the size of the Virtual Machine
$VMSize = "Standard_DS2_v2"

# Get the user credentials for the Virtual Machine
$Credential = Get-Credential

# Create a new Azure VM configuration
$vmConfig = New-AzVMConfig -Name $vmName -VMSize $VMSize -AvailabilitySetId $availabilitySet.Id

# Set the operating system for the Virtual Machine to Windows using the specified credentials
Set-AzVMOperatingSystem -VM $vmConfig -ComputerName $vmName -Credential $Credential -Windows

# Set the source image for the Virtual Machine to Windows Server 2022 Datacenter
Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest"

# Define the name for the Network Interface
$networkInterfaceName = "app-interface"

# Retrieve information about the Network Interface
$networkInterface = Get-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $resourceGroup

# Add the Network Interface to the Virtual Machine configuration
$Vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $networkInterface.Id

# Disable boot diagnostics for the Virtual Machine
Set-AzVMBootDiagnostic -Disable -VM $Vm

# Create a new Azure Virtual Machine in the specified resource group and location
New-AzVM -ResourceGroupName $resourceGroup -Location $Location -VM $Vm
