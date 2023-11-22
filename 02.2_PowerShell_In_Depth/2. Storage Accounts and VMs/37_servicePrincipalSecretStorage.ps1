# Disable automatic saving of Azure context and authenticate to Azure
Disable-AzContextAutosave
Connect-AzAccount

# Create a new Azure AD service principal with the specified display name
$servicePrincipalName = "new-principal"
$servicePrincipal = New-AzADServicePrincipal -DisplayName $servicePrincipalName

# Retrieve the service principal secret for further usage
$servicePrincipalSecret = $servicePrincipal.PasswordCredentials.SecretText

# Specify the Key Vault name where the service principal secret will be stored
$keyVaultName = "danmansaghfKJH"

# Convert the service principal secret to a secure string
$secretValue = ConvertTo-SecureString $servicePrincipalSecret -AsPlainText -Force

# Set the service principal secret as a Key Vault secret
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $servicePrincipalName -SecretValue $secretValue

# Retrieve the service principal object and its necessary credentials from Key Vault
$ServicePrincipal = Get-AzADServicePrincipal -DisplayName $servicePrincipalName
$AppId = $ServicePrincipal.AppId
$AppSecret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $servicePrincipalName -AsPlainText
$SecureSecret = $AppSecret | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $AppId, $SecureSecret

# Define the Azure Active Directory Tenant ID
$TenantId = "<tenant_id>"

# Disconnect from the current Azure account
Disconnect-AzAccount

# Connect to Azure using the service principal credentials and specified tenant
Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $TenantId

# Define the subscription name
$subscriptionName = "Azure Subscription 1"

# Retrieve the subscription object matching the specified subscription name
$subscription = Get-AzSubscription -SubscriptionName $subscriptionName

# Set the context of the current session to the retrieved subscription object
Set-AzContext -SubscriptionObject $subscription
