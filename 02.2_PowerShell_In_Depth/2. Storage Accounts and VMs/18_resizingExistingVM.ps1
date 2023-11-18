# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define VM size
$DesiredVMSize = "Standard_DS1_v2"

# Define the name for the Virtual Machine
$vmName = "appvm"

# Retrieve existing VM object
$existingVM = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName

if ($existingVM.HardwareProfile.VmSize -ne $DesiredVMSize) {
    # Update the VM's hardware profile with the desired size
    $existingVM.HardwareProfile.VmSize = $DesiredVMSize
    # Updating VM
    $existingVM | Update-AzVM
    "Changing VM size..."
}
else {
    "VM is already of the desired size."
}