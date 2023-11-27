# Define variables
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"

# Define Virtual Network details
$VirtualNetworkName = "app-network"
$VirtualNetworkAddressSpace = "10.0.0.0/16"
$SubnetName = "dbsubnet"
$SubnetAddressSpace = "10.0.1.0/24"

# Create Subnet configuration
$SubnetA = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

# Create Virtual Network
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
    -Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $SubnetA

# Retrieve Subnet configuration
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

# Create Network Interface
$NetworkInterfaceName = "db-interface"
$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet

# Create Public IP Address
$PublicIPAddressName = "db-ip"
$PublicIPAddress = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName `
    -Location $Location -Sku "Standard" -AllocationMethod "Static"

# Associate Public IP with Network Interface
$IpConfig = Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterface
$NetworkInterface | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddress `
    -Name $IpConfig.Name
$NetworkInterface | Set-AzNetworkInterface

# Define Network Security Rules
$SecurityRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$SecurityRule2 = New-AzNetworkSecurityRuleConfig -Name "Allow-SQL" -Description "Allow-SQL" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 1433

# Create Network Security Group
$NetworkSecurityGroupName = "db-nsg"
$NetworkSecurityGroup = New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -SecurityRules $SecurityRule1, $SecurityRule2

# Configure Network Security Group with Subnet
$VirtualNetworkName = "app-network"
$SubnetName = "dbsubnet"
$SubnetAddressSpace = "10.0.1.0/24"
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
    -NetworkSecurityGroup $NetworkSecurityGroup `
    -AddressPrefix $SubnetAddressSpace
$VirtualNetwork | Set-AzVirtualNetwork

# Define Azure VM settings
$VmName = "dbvm"
$VMSize = "Standard_DS2_v2"
$UserName = "sqladmin"
$Password = "Azure@123"
$PasswordSecure = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $UserName, $PasswordSecure

# Get Network Interface details
$NetworkInterfaceName = "db-interface"
$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName

# Create Azure VM configuration
$VmConfig = New-AzVMConfig -Name $VmName -VMSize $VMSize

# Set OS and Image for VM
Set-AzVMOperatingSystem -VM $VmConfig -ComputerName $VmName `
    -Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig -PublisherName "MicrosoftSQLServer" `
    -Offer "sql2019-ws2019" -Skus "sqldev" -Version "latest"

# Associate Network Interface with VM
$Vm = Add-AzVMNetworkInterface -VM $VmConfig -Id $NetworkInterface.Id

# Disable Boot Diagnostics
Set-AzVMBootDiagnostic -Disable -VM $Vm

# Create the Azure Virtual Machine
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
    -VM $Vm

# Configure Custom Script Extension for VM
$AccountName = "dbstore500098989"
$ResourceGroupName = "powershell-grp"
$ContainerName = "scripts"
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName 

# Retrieve script from Azure Blob Storage
$Blob = Get-AzStorageBlob -Blob "InitScript.ps1" -Container $ContainerName `
    -Context $StorageAccount.Context
$blobUri = @($Blob.ICloudBlob.Uri.AbsoluteUri)
$settings = @{"fileUris" = $blobUri }

# Configure settings for executing script on VM
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $AccountName) | Where-Object { $_.KeyName -eq "key1" }
$StorageAccountKeyValue = $StorageAccountKey.Value
$protectedSettings = @{"storageAccountName" = $AccountName; "storageAccountKey" = $StorageAccountKeyValue; "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File InitScript.ps1" };
$protectedSettings

# Set up Custom Script Extension for execution
Set-AzVMExtension -ResourceGroupName $ResourceGroupName -Location $Location `
    -VMName $VMName -Name "ConfigureSQL" -Publisher "Microsoft.Compute" `
    -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
    -Settings $settings -ProtectedSettings $protectedSettings
