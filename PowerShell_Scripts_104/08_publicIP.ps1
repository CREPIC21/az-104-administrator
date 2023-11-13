# Define the geographic location
$location = "North Europe"

# Define the name of the Azure Resource Group
$resourceGroupName = "dan-grp"

# Define the name of the Azure Public IP address
$publicIpName = "dan-ip"

# Use New-AzPublicIpAddress to create a new Azure Public IP address
New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Dynamic
