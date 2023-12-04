# Define variables for the Azure environment
$Location = "North Europe"
$VirtualNetworkName = "staging-network"
$VirtualNetworkAddressSpace = "10.0.0.0/16"
$SubnetName = "StagingSubnet"
$SubnetAddressSpace = "10.0.0.0/24"
$ResourceGroupName = "powershell-grp"

# Create a subnet configuration
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

# Create a new virtual network
' Creating the Virtual Network'
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
    -Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet

# Get subnet configuration for the created virtual network
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

# Define and create a network interface
$NetworkInterfaceName = "staging-interface"
$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet

# Define and create a public IP address
$PublicIPAddressName = "staging-ip"
$PublicIPAddress = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName `
    -Location $Location -Sku "Standard" -AllocationMethod "Static"

# Configure IP address for the network interface
$IpConfig = Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterface
$NetworkInterface | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddress `
    -Name $IpConfig.Name

# Apply network interface changes
$NetworkInterface | Set-AzNetworkInterface

# Define and create a network security rule for RDP
$SecurityRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

# Create a network security group
$NetworkSecurityGroupName = "staging-nsg"
$NetworkSecurityGroup = New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -SecurityRules $SecurityRule1

# Update the virtual network's subnet with the created network security group
$VirtualNetworkName = "staging-network"
$SubnetName = "StagingSubnet"
$SubnetAddressSpace = "10.0.0.0/24"
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
    -NetworkSecurityGroup $NetworkSecurityGroup `
    -AddressPrefix $SubnetAddressSpace
$VirtualNetwork | Set-AzVirtualNetwork

# Define VM configuration settings
$VmName = "stagingvm"
$VMSize = "Standard_DS2_v2"
$Location = "North Europe"
$UserName = "demousr"
$Password = "Azure@123"

# Convert password to a secure string
$PasswordSecure = ConvertTo-SecureString -String $Password -AsPlainText -Force

# Create credentials for the VM
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $UserName, $PasswordSecure

# Get the network interface for the VM
$NetworkInterfaceName = "staging-interface"
$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName

# Create a VM configuration
$VmConfig = New-AzVMConfig -Name $VmName -VMSize $VMSize

# Configure the VM's operating system settings
Set-AzVMOperatingSystem -VM $VmConfig -ComputerName $VmName `
    -Credential $Credential -Windows

# Set the VM's source image
Set-AzVMSourceImage -VM $VmConfig -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"

# Attach the network interface to the VM
$Vm = Add-AzVMNetworkInterface -VM $VmConfig -Id $NetworkInterface.Id

# Disable boot diagnostics for the VM
Set-AzVMBootDiagnostic -Disable -VM $Vm

# Create the VM
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
    -VM $Vm
