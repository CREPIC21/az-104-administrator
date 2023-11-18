$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershe22536253"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$Containers = "containera123", "containerb123", "containerc123"

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
foreach ($ContainerName in $Containers) {
    if (Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue) {
        'Container already exists.'
        $Container = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context
    }
    else {
        'Creating the container...'
        $Container = New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob
    }
}