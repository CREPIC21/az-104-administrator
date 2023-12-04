# Set variables for Azure resources
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$VirtualNetworkName = "app-network"
$VirtualNetworkAddressSpace = "10.0.0.0/16"
$SubnetName = "SubnetA"
$SubnetAddressSpace = "10.0.0.0/24"

# Create subnet configuration for the virtual network
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

# Create a new virtual network in the specified resource group with the defined subnet
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
    -Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet

# Retrieve subnet configuration from the created virtual network
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

# Create a network interface in the subnet
$NetworkInterfaceName = "app-interface"
$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet

# Create a network security rule allowing RDP traffic
$SecurityRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

# Create a network security group and associate the rule
$NetworkSecurityGroupName = "app-nsg"
$NetworkSecurityGroup = New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -SecurityRules $SecurityRule1

# Update subnet configuration with the created network security group
$VirtualNetworkName = "app-network"
$SubnetName = "SubnetA"
$SubnetAddressSpace = "10.0.0.0/24"

$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
    -NetworkSecurityGroup $NetworkSecurityGroup `
    -AddressPrefix $SubnetAddressSpace

$VirtualNetwork | Set-AzVirtualNetwork

# Define VM configurations for deployment
$VmName = "appvm"
$VMSize = "Standard_DS2_v2"
$Location = "North Europe"
$UserName = "demousr"
$Password = "Azure@123"

# Convert the password to a secure string
$PasswordSecure = ConvertTo-SecureString -String $Password -AsPlainText -Force

# Create credentials for the VM
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $UserName, $PasswordSecure

# Retrieve the network interface for the VM
$NetworkInterfaceName = "app-interface"
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

# Create the VM in the specified resource group and location
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
    -VM $Vm
