$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "danman736353"
$StorageAccountKind = "StorageV2"
$StorageAccountSKU = "Standard_LRS"


New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$StorageAccount = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind $StorageAccountKind -SkuName $StorageAccountSKU -AllowBlobPublicAccess $true -Debug

$StorageAccount