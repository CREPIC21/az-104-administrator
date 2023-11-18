$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershe22536253"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$ContainerName = "data"

# Check for the existance of storage account
if (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
    'Storage account already exists.'
    $StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
}
else {
    'Creating the storage account...'
    $StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true
}

# Check for the existance of container
if (Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context) {
    'Container already exists.'
    $Container = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context
}
else {
    'Creating the container...'
    $Container = New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob
}

# Check for the existance of blob
if (Get-AzStorageBlob -Context $StorageAccount.Context -Container $ContainerName -Blob $BlobObject.ObjectName -ErrorAction SilentlyContinue) {
    'Blob already exists.'
    $Blob = Get-AzStorageBlob -Context $StorageAccount.Context -Container $ContainerName -Blob $BlobObject.ObjectName
}
else {
    'Creating the blob...'
    $BlobObject = @{
        FileLocation = "sampleFile.txt"
        ObjectName   = "sample.txt"
    }
    
    Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName -File $BlobObject.FileLocation -Blob $BlobObject.ObjectName
}


