# Define Azure Resource Group
$ResourceGroupName = "powershell-grp"

# Get all VMs in the specified Resource Group
$VMs = Get-AzVM -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -Like "appvm*" }

# Get the count of VMs
$NumberofMachines = $VMs.Count

# Storage Account details
$AccountName = "vmstore400089891"
$ContainerName = "scripts"

# Retrieve Storage Account details
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName

# Define Blob details
$BlobName = "IIS_Config.ps1"
$Blob = Get-AzStorageBlob -Context $StorageAccount.Context -Container $ContainerName -Blob $BlobName

# Obtain Blob URI
$blobUri = @($Blob.ICloudBlob.Uri.AbsoluteUri)

# Retrieve Storage Account key
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $AccountName) | Where-Object { $_.KeyName -eq "key1" }

# Define script settings and protected settings for VM extension
$settings = @{"fileUris" = $blobUri }
$StorageAccountKeyValue = $StorageAccountKey.Value
$protectedSettings = @{
    "storageAccountName" = $AccountName;
    "storageAccountKey"  = $StorageAccountKeyValue;
    "commandToExecute"   = "powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"
}

# Loop through each VM and apply the VM extension with defined settings and protected settings
for ($i = 1; $i -le $NumberofMachines; $i++) {
    Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
        -VMName $VMs[$i - 1].Name -Name "IISExtension" -Publisher "Microsoft.Compute" `
        -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
        -Settings $settings -ProtectedSettings $protectedSettings
}
