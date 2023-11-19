# Define variables for the resource group, storage account name, location, and container name
$resourceGroup = "powershell-grp"
$location = "North Europe"
$StorageAccountName = "powershell096253"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$ContainerName = "data"

# Create a new Azure Storage Account with the specified name, resource group, location, kind, SKU, and allow public access to blobs
$StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $resourceGroup -Location $location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true

# Display details of the retrieved storage account
$StorageAccount

# Create a new storage container within the specified storage account context and set permissions to Blob
New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob

# Define a hash table for Blob object details (file location and object name)
$BlobObject = @{
    FileLocation = "./26_IIS_Config.ps1"
    ObjectName   = "26_IIS_Config.ps1"
}

# Upload a file to the specified storage container with the specified blob name
$blob = Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName -File $BlobObject.FileLocation -Blob $BlobObject.ObjectName

# Define the Azure Virtual Network name
$networkName = "app-network"

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
    -Location $location -AllocationMethod "Static"

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

# Define the name for the Virtual Machine
$vmName = "appvm"

# Define the size of the Virtual Machine
$VMSize = "Standard_DS2_v2"

# Get the user credentials for the Virtual Machine
$Credential = Get-Credential

# Create a new Azure VM configuration
$vmConfig = New-AzVMConfig -Name $vmName -VMSize $VMSize

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

# Attach new data disk to created VM
$diskName = "app-disk"

# Retrieve existing VM object
$existingVM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName

# Adding new data disk
$existingVM | Add-AzVMDataDisk -Name $diskName -DiskSizeInGB 16 -CreateOption Empty -Lun 0

# Updating VM
$existingVM | Update-AzVM

# Apply custom script extension
$blobURL = @($blob.ICloudBlob.Uri.AbsoluteUri)
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $StorageAccountName) | Where-Object { $_.KeyName -eq "key1" }
$storageAccountKeyValue = $storageAccountKey.Value

$settings = @{"fileUris" = $blobURL }
$protectedSettings = @{"storageAccountName" = $StorageAccountName; "storageAccountKey" = $storageAccountKeyValue; "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File 26_IIS_Config.ps1" }

Set-AzVMExtension -ResourceGroupName $resourceGroup -Location $location -VMName $vmName -Name "IISExtension" -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
    -Settings $settings -ProtectedSettings $protectedSettings
