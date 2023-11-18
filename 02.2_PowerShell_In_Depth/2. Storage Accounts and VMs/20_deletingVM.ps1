# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the name for the Virtual Machine
$vmName = "appvm"

# Retrieve existing VM object
$existingVM = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName

# Deleting data disks associated with the VM
foreach ($DataDisk in $existingVM.StorageProfile.DataDisks) {
    $DataDisk.Name

    # Displaying and removing each data disk from the VM
    "Removing Data Disk " + $DataDisk.Name
    Remove-AzVMDataDisk -VM $existingVM -DataDiskNames $DataDisk.Name
    $existingVM | Update-AzVM

    # Removing the disk from Azure after detaching it from the VM
    Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $DataDisk.Name | Remove-AzDisk -Force
}

# Deleting public IP addresses associated with the VM's network interfaces
foreach ($Interface in $existingVM.NetworkProfile.NetworkInterfaces) {
    # Get the network interface and its associated public IP address
    $NetworkInterface = Get-AzNetworkInterface -ResourceId $Interface.Id
    $PublicAddress = Get-AzResource -ResourceId $NetworkInterface.IpConfigurations.publicIPAddress.Id

    # Unlinking the public IP address from the network interface
    $NetworkInterface.IpConfigurations.publicIPAddress.Id = $null
    $NetworkInterface | Set-AzNetworkInterface

    # Removing the public IP address resource
    "Removing public IP address " + $PublicAddress.Name
    Remove-AzPublicIpAddress -ResourceGroupName $resourceGroup -Name $PublicAddress.Name
}

# Storing the VM's OS disk
$osDisk = $existingVM.StorageProfile.OsDisk

# Deleting the VM
"Deleting the VM..."
Remove-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Force

# Deleting the network interface associated with the VM
"Deleting NIC..."
$NetworkInterface | Remove-AzNetworkInterface -Force

# Deleting the VM's OS disk
"Deleting OS disk..."
Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $osDisk.Name | Remove-AzDisk -Force

# Deleting the resource group and all its resources
"Deleting the resource group and all the resources inside of it..."
Remove-AzResourceGroup -Name $resourceGroup -Force
