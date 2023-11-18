# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define VM size
$DesiredVMSize = "Standard_DS1_v2"

# Define the name for the Virtual Machine
$vmName = "appvm"

# Retrieve existing VM object using its resource group and name
$existingVM = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName

# Check if the existing VM's size is different from the desired size
if ($existingVM.HardwareProfile.VmSize -ne $DesiredVMSize) {
    # Update the VM's hardware profile with the desired size
    $existingVM.HardwareProfile.VmSize = $DesiredVMSize
    
    # Update the VM with the new size
    $existingVM | Update-AzVM
    
    "Changing VM size..."
}
else {
    "VM is already of the desired size."
}
