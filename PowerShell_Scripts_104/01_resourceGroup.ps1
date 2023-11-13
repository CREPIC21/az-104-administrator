# Define the resource group name
$resourceGroupName = "dan-grp"

# Define the location for the resource group (in this case, "North Europe")
$location = "North Europe"

# Create a new Azure Resource Group with the specified name and location
New-AzResourceGroup -Name $resourceGroupName -Location $location
