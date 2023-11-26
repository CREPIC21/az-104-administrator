# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the geographic location
$location = "North Europe"

# Define the name for the App Service Plan
$appServiceName = "appplandanman02"

# Define the name for the Web App
$webAppName = "webapp5563279402"

# Define properties for repository integration (GitHub in this case)
$properties = @{
    repoUrl             = "https://github.com/CREPIC21/DanManWebApp";
    branch              = "master";
    isManualIntegration = "true";
}

# Define deployment slot names
$slotName = "Staging"
$targetSlot = "production"

# Create a new Azure App Service Plan with the specified parameters - using 'Standard' tier for deployment slots
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Location $location `
    -Name $appServiceName -Tier "Standard" -NumberofWorkers 1

# Create a new Azure Web App with the specified parameters and link it to the App Service Plan
New-AzWebApp -ResourceGroupName $resourceGroup -Name $webAppName `
    -Location $location -AppServicePlan $appServiceName

# Set properties for source control integration for the Web App (GitHub in this case)
Set-AzResource -ResourceGroupName $resourceGroup -Properties $properties -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $webAppName/web -ApiVersion 2015-08-01 -Force

# Create a deployment slot named 'Staging' for the Web App
New-AzWebAppSlot -Name $webAppName -ResourceGroupName $resourceGroup -Slot $slotName

# Swap deployment slots from 'Staging' to 'Production'
Switch-AzWebAppSlot -Name $webAppName -ResourceGroupName $resourceGroup -SourceSlotName $slotName -DestinationSlotName $targetSlot
