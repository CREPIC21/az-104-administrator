# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the name for the Virtual Machine
$vmName = "appvm"

# Attach new data disk to created VM
$diskName = "app-disk"

# Retrieve existing VM object
$existingVM = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName

# Adding new data disk
$existingVM | Add-AzVMDataDisk -Name $diskName -DiskSizeInGB 16 -CreateOption Empty -Lun 0

# Updating VM
$existingVM | Update-AzVM
