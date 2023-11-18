# Define variables for the resource group, storage account name, kind, and SKU
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershe22536253"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"

# Create a new Azure Resource Group with the specified name and location
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Create a new Azure Storage Account with the specified name, resource group, location, kind, SKU, and allow public access to blobs
$StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true

# Display details of the newly created storage account
$StorageAccount
