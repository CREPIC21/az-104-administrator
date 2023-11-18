# Define variables for the resource group name and location
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"

# Remove the Azure Resource Group and all its resources (force deletion)
Remove-AzResourceGroup -Name $ResourceGroupName -Force

# Display a message indicating the removal of the resource group
'Removed Resource Group ' + $ResourceGroupName

# Create a new Azure Resource Group with the specified name and location
$ResourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Display the provisioning state of the newly created resource group
'Provisioning State of resource group: ' + $ResourceGroup.ProvisioningState

# Retrieve information about the existing resource group with the specified name
$ResourceGroupExisting = Get-AzResourceGroup -Name $ResourceGroupName

# Display the details of the new resource group and the existing resource group
$ResourceGroup
$ResourceGroupExisting

# Get all Azure Resource Groups
$AllResourceGroups = Get-AzResourceGroup

# Loop through each resource group and remove them (force deletion)
foreach ($Group in $AllResourceGroups) {
    'Removing RG: ' + $Group.ResourceGroupName
    Remove-AzResourceGroup -Name $Group.ResourceGroupName -Force
}
