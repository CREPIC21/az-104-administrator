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

# Creating fileshare
'Creating the fileshare...'
$FileShareConfig = @{
    Context = $StorageAccount.Context
    Name    = "data"
}
# splatting
New-AzStorageShare @FileShareConfig


$DirectoryDetails = @{
    Context   = $StorageAccount.Context
    ShareName = "data"
    Path      = "files"
}
New-AzStorageDirectory @DirectoryDetails

$FileDetails = @{
    Context   = $StorageAccount.Context
    ShareName = "data"
    Source    = "sampleFile.txt"
    Path      = "/files/sample.txt"
}
Set-AzStorageFileContent @FileDetails



