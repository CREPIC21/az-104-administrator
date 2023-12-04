# Disable automatic context autosave in Azure PowerShell
Disable-AzContextAutosave

# Define variables for creating a new Azure Resource Group
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"

# Create a new Azure Resource Group with the specified name and location
New-AzResourceGroup -Name $ResourceGroupName -Location $Location
