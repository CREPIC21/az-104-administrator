# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the geographic location
$location = "North Europe"

# Define the name for the App Service Plan
$appServiceName = "appplandanman01"

# Define the name for the Web App
$webAppName = "webapp5563279401"

# Define properties for repository integration (GitHub in this case)
$properties = @{
    repoUrl             = "https://github.com/CREPIC21/DanManWebApp";
    branch              = "master";
    isManualIntegration = "true";
}

# Create a new Azure App Service Plan with the specified parameters
New-AzAppServicePlan -ResourceGroupName $resourceGroup -Location $location `
    -Name $appServiceName -Tier "B1" -NumberofWorkers 1

# Create a new Azure Web App with the specified parameters and link it to the App Service Plan
New-AzWebApp -ResourceGroupName $resourceGroup -Name $webAppName `
    -Location $location -AppServicePlan $appServiceName

# Set properties for source control integration for the Web App (GitHub in this case)
Set-AzResource -ResourceGroupName $resourceGroup -Properties $properties -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $webAppName/web -ApiVersion 2015-08-01 -Force

# Enable request tracing, HTTP logging, and detailed error logging for the Web App
Set-AzWebApp -ResourceGroupName $resourceGroup -Name $webAppName -RequestTracingEnabled $true -HttpLoggingEnabled $true -DetailedErrorLoggingEnabled $true

##################### ONCE DONE GO TO BELOW URL(modify it with your webapp URL) TO DOWNLOAD THE LOGS ##########################
####                                  webapp5563279401.scm.azurewebsites.net/api/dump                                      ####
###############################################################################################################################

