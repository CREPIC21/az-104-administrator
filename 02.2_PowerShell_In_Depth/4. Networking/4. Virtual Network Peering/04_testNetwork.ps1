# Define variables for the Azure environment
$Location = "North Europe"
$VirtualNetworkName = "test-network"
$VirtualNetworkAddressSpace = "10.1.0.0/16"
$SubnetName = "TestSubnet"
$SubnetAddressSpace = "10.1.0.0/24"
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
$NetworkInterfaceName = "test-interface"
$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet

# Define and create a network security rule for HTTP
$SecurityRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80

# Create a network security group
$NetworkSecurityGroupName = "test-nsg"
$NetworkSecurityGroup = New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -SecurityRules $SecurityRule1

# Update the virtual network's subnet with the created network security group
$VirtualNetworkName = "test-network"
$SubnetName = "TestSubnet"
$SubnetAddressSpace = "10.1.0.0/24"
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
    -NetworkSecurityGroup $NetworkSecurityGroup `
    -AddressPrefix $SubnetAddressSpace
$VirtualNetwork | Set-AzVirtualNetwork

# Define VM configuration settings
$VmName = "testvm"
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
$NetworkInterfaceName = "test-interface"
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

# Define variables for Azure Storage Account and container
$AccountName = "danmanstore40008989"
$ContainerName = "scripts"

# Retrieve the specified Storage Account details
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName `
    -Name $AccountName

# Define the name of the blob (file) to be retrieved from the Storage Account
$BlobName = "IIS_Config.ps1"

# Get the specific blob from the Storage Account
$Blob = Get-AzStorageBlob -Context $StorageAccount.Context `
    -Container $ContainerName -Blob $BlobName

# Extract the URI of the blob
$blobUri = @($Blob.ICloudBlob.Uri.AbsoluteUri)

# Retrieve the primary access key for the Storage Account
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
        -AccountName $AccountName) | Where-Object { $_.KeyName -eq "key1" }

# Define settings for the custom script extension using the blob URI
$settings = @{"fileUris" = $blobUri }

# Extract the value of the primary access key for the Storage Account
$StorageAccountKeyValue = $StorageAccountKey.Value

# Define protected settings (credentials and command) for the custom script extension
$protectedSettings = @{"storageAccountName" = $AccountName; "storageAccountKey" = $StorageAccountKeyValue; `
        "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"
};

# Set the custom script extension for a specific VM to execute the PowerShell script
Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
    -VMName $VmName -Name "IISExtension" -Publisher "Microsoft.Compute" `
    -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
    -Settings $settings -ProtectedSettings $protectedSettings

