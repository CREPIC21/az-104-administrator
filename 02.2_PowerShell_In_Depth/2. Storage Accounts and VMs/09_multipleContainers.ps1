# Define variables for the resource group, location, storage account name, kind, SKU, and container names
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershe22536253"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"
$Containers = "containera123", "containerb123", "containerc123"

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

# Check if the containers already exist within the storage account context
foreach ($ContainerName in $Containers) {
    if (Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue) {
        'Container already exists.'
        $Container = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context
    }
    else {
        'Creating the container...'
        # Create the container if it doesn't exist
        $Container = New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob
    }
}
