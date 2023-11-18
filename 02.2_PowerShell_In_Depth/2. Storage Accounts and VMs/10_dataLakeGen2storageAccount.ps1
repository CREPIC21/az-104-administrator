$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "danman93026172"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$ContainerName = "data"
$DirectoryPath = "directory"
$DestinationFileName = "sample.txt"
$LocalFilePath = "sampleFile.txt"

# Check for the existance of storage account
if (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
    'Storage account already exists.'
    $StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
    # $StorageAccount
}
else {
    'Creating the storage account...'
    $StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true -EnableHierarchicalNamespace $true
}

# Check for the existance of container
if (Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue) {
    'Container already exists.'
    $Container = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context
    # $Container
}
else {
    'Creating the container...'
    $Container = New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob
}

# Check for the existance of directory
if (Get-AzDataLakeGen2Item -FileSystem $ContainerName -Context $StorageAccount.Context -Path $DirectoryPath) {
    'Directory already exists.'
    $Directory = Get-AzDataLakeGen2Item -FileSystem $ContainerName -Context $StorageAccount.Context -Path $DirectoryPath
    $Directory
}
else {
    'Creating the directory...'
    $Directory = New-AzDataLakeGen2Item -Context $StorageAccount.Context -FileSystem $ContainerName -Path $DirectoryPath -Directory
}

# Check for the existance of the file in the directory
if (Get-AzDataLakeGen2Item -FileSystem $ContainerName -Path "$DirectoryPath/$DestinationFileName" -Context $StorageAccount.Context -ErrorAction SilentlyContinue) {
    'File already exists.'
    $File = Get-AzDataLakeGen2Item -FileSystem $ContainerName -Path "$DirectoryPath/$DestinationFileName" -Context $StorageAccount.Context
    $File
}
else {
    'Creating the file...'
    $File = New-AzDataLakeGen2Item -Context $StorageAccount.Context -FileSystem $ContainerName -Path "$DirectoryPath/$DestinationFileName" -Source $LocalFilePath
}


