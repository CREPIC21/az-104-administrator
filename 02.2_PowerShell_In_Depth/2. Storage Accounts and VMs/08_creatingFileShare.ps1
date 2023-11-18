# Define variables for the resource group, location, storage account name, kind, SKU, and container name
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershe22536253"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$ContainerName = "data"

# Check if the storage account already exists in the specified resource group
if (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
    'Storage account already exists.'
    $StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
}
else {
    'Creating the storage account...'
    # Create a new storage account if it doesn't exist
    $StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true
}

# Creating a file share within the storage account
'Creating the fileshare...'
$FileShareConfig = @{
    Context = $StorageAccount.Context
    Name    = "data"
}
# Create the file share using splatting
New-AzStorageShare @FileShareConfig

# Creating a directory within the file share
$DirectoryDetails = @{
    Context   = $StorageAccount.Context
    ShareName = "data"
    Path      = "files"
}
New-AzStorageDirectory @DirectoryDetails

# Uploading a file to the created directory within the file share
$FileDetails = @{
    Context   = $StorageAccount.Context
    ShareName = "data"
    Source    = "sampleFile.txt"
    Path      = "/files/sample.txt"
}
Set-AzStorageFileContent @FileDetails
