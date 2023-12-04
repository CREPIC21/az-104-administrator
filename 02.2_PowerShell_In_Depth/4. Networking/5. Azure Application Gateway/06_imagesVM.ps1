# Define variables for the Azure environment
$VirtualNetworkName = "app-network"
$ResourceGroupName = "powershell-grp"

# Retrieve the existing virtual network details by name and resource group
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Get the subnet configuration of the virtual network
$SubnetConfig = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName | Get-AzVirtualNetworkSubnetConfig

# Define a network interface in the specified subnet
$NetworkInterfaceName = "img-interface"
$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $SubnetConfig[0]

# Create a network security rule allowing HTTP traffic
$SecurityRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80

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
$VmName = "imagesvm"
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
$NetworkInterfaceName = "img-interface"
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

# Define configurations to execute a PowerShell script on the VM
$AccountName = "danmanstore40008989"
$ContainerName = "scripts"

# Retrieve the specified Storage Account details
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName `
    -Name $AccountName

# Get the specific blob from the Storage Account
$BlobName = "IIS_Config_Image.ps1"
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
        "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File IIS_Config_Image.ps1"
};

# Set the custom script extension for a specific VM to execute the retrieved PowerShell script
Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
    -VMName $VmName -Name "IISExtension" -Publisher "Microsoft.Compute" `
    -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
    -Settings $settings -ProtectedSettings $protectedSettings
