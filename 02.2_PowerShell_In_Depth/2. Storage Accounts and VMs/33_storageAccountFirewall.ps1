# Define variables for the resource group, storage account name, kind, and SKU
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershe22536253"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$ContainerName = "data"

# Create a new Azure Storage Account with specified settings: name, resource group, location, kind, SKU, and allow public access to blobs
$StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true

# Create a new storage container within the specified storage account context and set permissions to Blob
New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob

# Define a hash table for Blob object details (file location and object name)
$BlobObject = @{
    FileLocation = "sampleFile.txt"
    ObjectName   = "sample.txt"
}

# Upload a file to the specified storage container with the specified blob name
Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName -File $BlobObject.FileLocation -Blob $BlobObject.ObjectName

# Update the network rules for the storage account to deny all traffic by default
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -DefaultAction Deny

# Retrieve the public IP address of the current machine
$myIPAddress = Invoke-WebRequest -Uri "https://ifconfig.me/ip" | Select-Object Content

# Add the current public IP address to the storage account's allowed IP addresses or ranges
Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -IPAddressOrRange $myIPAddress.Content

# Retrieve the virtual network information
$networkName = "app-network"
$virtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $ResourceGroupName

# Retrieve the subnet configuration within the virtual network
$subnetConfig = $virtualNetwork | Get-AzVirtualNetworkSubnetConfig

# Configure the subnet to use service endpoint for Microsoft.Storage
Set-AzVirtualNetworkSubnetConfig -Name $subnetConfig[0].Name -ServiceEndpoint "Microsoft.Storage" -VirtualNetwork $virtualNetwork -AddressPrefix $subnetConfig[0].AddressPrefix | Set-AzVirtualNetwork

# Add the storage account to the allowed list of resources within the specified subnet
Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -VirtualNetworkResourceId $subnetConfig[0].Id
