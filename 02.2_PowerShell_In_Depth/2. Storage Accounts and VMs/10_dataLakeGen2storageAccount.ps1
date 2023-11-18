# Define variables for the resource group, location, storage account name, kind, SKU, container name, directory path, destination file name, and local file path
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "danman93026172"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$ContainerName = "data"
$DirectoryPath = "directory"
$DestinationFileName = "sample.txt"
$LocalFilePath = "sampleFile.txt"

# Check if the storage account already exists in the specified resource group
if (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
    'Storage account already exists.'
    $StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
}
else {
    'Creating the storage account...'
    # Create a new storage account if it doesn't exist
    $StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true -EnableHierarchicalNamespace $true
}

# Check if the container already exists within the storage account context
if (Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue) {
    'Container already exists.'
    $Container = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context
}
else {
    'Creating the container...'
    # Create the container if it doesn't exist
    $Container = New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob
}

# Check if the directory already exists within the container
if (Get-AzDataLakeGen2Item -FileSystem $ContainerName -Context $StorageAccount.Context -Path $DirectoryPath) {
    'Directory already exists.'
    $Directory = Get-AzDataLakeGen2Item -FileSystem $ContainerName -Context $StorageAccount.Context -Path $DirectoryPath
}
else {
    'Creating the directory...'
    # Create the directory if it doesn't exist
    $Directory = New-AzDataLakeGen2Item -Context $StorageAccount.Context -FileSystem $ContainerName -Path $DirectoryPath -Directory
}

# Check if the file already exists within the directory
if (Get-AzDataLakeGen2Item -FileSystem $ContainerName -Path "$DirectoryPath/$DestinationFileName" -Context $StorageAccount.Context -ErrorAction SilentlyContinue) {
    'File already exists.'
    $File = Get-AzDataLakeGen2Item -FileSystem $ContainerName -Path "$DirectoryPath/$DestinationFileName" -Context $StorageAccount.Context
}
else {
    'Creating the file...'
    # Create the file by uploading it to the specified directory within the container
    $File = New-AzDataLakeGen2Item -Context $StorageAccount.Context -FileSystem $ContainerName -Path "$DirectoryPath/$DestinationFileName" -Source $LocalFilePath
}
