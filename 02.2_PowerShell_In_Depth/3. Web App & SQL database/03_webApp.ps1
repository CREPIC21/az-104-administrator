# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the geographic location
$location = "North Europe"

# Define the name for the App Service Plan
$appServiceName = "appplandanman"

# Define the name for the Web App
$webAppName = "webapp55632794"

# Create a new Azure App Service Plan with the specified parameters
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Location $location `
    -Name $appServiceName -Tier "B1" -NumberofWorkers 1

# Create a new Azure Web App with the specified parameters and link it to the App Service Plan
New-AzWebApp -ResourceGroupName $resourceGroup -Name $webAppName `
    -Location $location -AppServicePlan $appServiceName
