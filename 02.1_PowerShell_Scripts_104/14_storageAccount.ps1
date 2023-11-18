# Define the Azure Resource Group name
$resourceGroup = "dan-grp"

# Define the geographic location
$location = "North Europe"

# Define the SKU for the storage account
$accountSKU = "Standard_LRS"

# Define the name for the storage account
$storageAccountName = "danstore4443434"

# Define the kind of storage account
$storageAccountKind = "StorageV2"

# Create a new Azure Storage Account with the specified parameters
New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName `
    -Location $location -Kind $storageAccountKind -SkuName $accountSKU
