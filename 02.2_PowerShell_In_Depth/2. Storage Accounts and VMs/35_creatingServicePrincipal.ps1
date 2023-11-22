# Disable automatic saving of Azure context and authenticate to Azure
Disable-AzContextAutosave
Connect-AzAccount

# Create a new Azure AD service principal with the specified display name
$servicePrincipalName = "app-principal"
$servicePrincipal = New-AzADServicePrincipal -DisplayName $servicePrincipalName

# Retrieve the service principal's ID and secret for further usage
$servicePrincipalID = $servicePrincipal.Id
$servicePrincipalSecret = $servicePrincipal.PasswordCredentials.SecretText

# Output the service principal's ID and secret
$servicePrincipalID
$servicePrincipalSecret

# Retrieve the subscription object for a specific subscription name
$subscription = Get-AzSubscription -SubscriptionName "Azure subscription 1"

# Define the scope and role for role assignment
$scope = "/subscriptions/$subscription"
$roleDefinition = "Contributor"

# Assign the 'Contributor' role to the service principal at the defined scope
New-AzRoleAssignment -ObjectId $servicePrincipalID -RoleDefinitionName $roleDefinition -Scope $scope

# Disconnect from the current Azure account
Disconnect-AzAccount

# Define resource group and location
$resourceGroup = "demo-grp"
$location = "North Europe"

# Retrieve the application ID for the service principal
$AppId = $servicePrincipal.AppId

# Convert the service principal secret to a secure string
$SecureSecret = $servicePrincipalSecret | ConvertTo-SecureString -AsPlainText -Force

# Create a PSCredential object for authentication
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $AppId, $SecureSecret

# Define the Azure Active Directory Tenant ID
$TenantId = "<tenant_id>"

# Connect to Azure using service principal credentials and specified tenant
Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $TenantId

# Create a new Azure resource group
New-AzResourceGroup -Name $resourceGroup -Location $location
