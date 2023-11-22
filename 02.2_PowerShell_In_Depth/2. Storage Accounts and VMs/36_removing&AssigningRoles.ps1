# Define resource group and location
$resourceGroup = "powershell-grp"

# Connect to Azure
Connect-AzAccount

# Define service principal name and retrieve the service principal object by display name
$servicePrincipalName = "app-principal"
$servicePrincipal = Get-AzADServicePrincipal -DisplayName $servicePrincipalName
$servicePrincipalID = $servicePrincipal.Id

# Retrieve the subscription object for a specific subscription name
$subscription = Get-AzSubscription -SubscriptionName "Azure subscription 1"

# Define the scope and role for role assignment to a specific resource group
$scope = "/subscriptions/$subscription/resourcegroups/$resourceGroup"
$roleDefinition = "Storage Account Contributor"

# Assign the 'Storage Account Contributor' role to the service principal at the defined resource group scope
New-AzRoleAssignment -ObjectId $servicePrincipalID -RoleDefinitionName $roleDefinition -Scope $scope

# Redefine scope and role for removing a role assignment at the subscription level
$scope = "/subscriptions/$subscription"
$roleDefinition = "Contributor"

# Remove the 'Contributor' role assignment for the service principal at the subscription scope
Remove-AzRoleAssignment -ObjectId $servicePrincipalID -RoleDefinitionName $roleDefinition -Scope $scope

# Disable automatic saving of Azure context and disconnect from Azure
Disable-AzContextAutosave
Disconnect-AzAccount
