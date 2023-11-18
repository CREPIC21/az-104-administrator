# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the name for the Virtual Machine
$vmName = "appvm"

# Retrieve existing VM status
$Statuses = (Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Status).Statuses 
$Statuses 
$Statuses[1].Code

if ($Statuses[1].Code -eq "PowerState/running") {
    "Shutting down the VM..."
    Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
}
else {
    "The VM is not in the running state."
}

