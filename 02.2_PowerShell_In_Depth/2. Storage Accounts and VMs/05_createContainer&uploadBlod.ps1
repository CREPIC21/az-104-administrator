$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershell536253"

$ContainerName = "data"

$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
$StorageAccount

New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob

$BlobObject = @{
    FileLocation = "sampleFile.txt"
    ObjectName   = "sample.txt"
}

Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName -File $BlobObject.FileLocation -Blob $BlobObject.ObjectName
