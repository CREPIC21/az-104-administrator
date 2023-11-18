# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the name for the Virtual Machine
$vmName = "appvm"

# Retrieve existing VM status
$Statuses = (Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Status).Statuses 

# Output the statuses array
$Statuses 

# Retrieve the code of the second status
$Statuses[1].Code

# Check if the VM is in a running state (based on the second status)
if ($Statuses[1].Code -eq "PowerState/running") {
    # If the VM is running, initiate the shutdown process
    "Shutting down the VM..."
    Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
}
else {
    # If the VM is not in a running state, indicate that it's not running
    "The VM is not in the running state."
}
