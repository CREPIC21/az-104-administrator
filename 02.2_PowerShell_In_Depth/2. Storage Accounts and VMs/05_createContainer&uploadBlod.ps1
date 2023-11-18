# Define variables for the resource group, storage account name, location, and container name
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$StorageAccountName = "powershell536253"
$ContainerName = "data"

# Retrieve the existing Azure Storage Account with the specified name and resource group
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName

# Display details of the retrieved storage account
$StorageAccount

# Create a new storage container within the specified storage account context and set permissions to Blob
New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob

# Define a hash table for Blob object details (file location and object name)
$BlobObject = @{
    FileLocation = "sampleFile.txt"
    ObjectName   = "sample.txt"
}

# Upload a file to the specified storage container with the specified blob name
Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName -File $BlobObject.FileLocation -Blob $BlobObject.ObjectName
