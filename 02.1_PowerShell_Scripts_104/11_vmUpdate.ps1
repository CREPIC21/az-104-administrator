# Define the name of the Azure Resource Group
$resourceGroupName = "dan-grp"

# Define the name of the virtual machine
$vmName = "danvm"

# Define the name of the data disk to be added to the virtual machine
$diskName = "dan-disk"

# Get the virtual machine with the specified name and resource group
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Add a new data disk to the virtual machine
$vm | Add-AzVMDataDisk -Name $diskName -DiskSizeInGB 16 -CreateOption Empty -Lun 0

# Update the virtual machine with the new data disk configuration
$vm | Update-AzVM
