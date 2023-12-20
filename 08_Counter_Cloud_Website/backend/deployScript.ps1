<#
This PowerShell script configures a web infrastructure on Azure. It involves deploying a storage account for hosting a static website, enabling static website functionality on that account, 
uploading necessary website files (HTML, CSS, and JavaScript) to the storage, deploying a CDN (Content Delivery Network) profile, and finally configuring a custom domain for the 
CDN endpoint to make the site accessible through a custom domain name, ensuring efficient content delivery and scalability. Overall, it's a series of steps to create and configure the 
infrastructure required to host a static website and improve its performance using Azure services like Storage and CDN using ARM templates and PowerShell.
#>

# Variables Setup
$subscriptionName = "Azure Subscription 1"
$ResourceGroupName = "web-grp"
$TemplateFileStorageCdnProfileDnsZone = ".\arm_templates\storage_dns_cdn_funcApp\storagecdndnszone.json"
$TemplateFileStorageCdnProfileParametersDnsZone = ".\arm_templates\storage_dns_cdn_funcApp\storagecdndnszone.parameters.json"
$TemplateCosmosDB = ".\arm_templates\cosmosDB_keyVault\cosmosDBkeyVault.json"
$TemplateCosmosDBParameters = ".\arm_templates\cosmosDB_keyVault\cosmosDBkeyVault.parameters.json"
$CreateEntitiesScript = ".\js_scripts\createEntities.js"
$EnableCustomHTTPSCDNScript = ".\js_scripts\enablecustomHTTPS.js"
$StorageAccountName = "resumestoragedc"
$ProfileName = "resumeprofile"
$EndpointName = "resumestoragedc";
$CustomDomainName = "resume-mycloudproject-online"
$IndexDocument = "index.html"
$ErrorDocument = "error.html"

# Azure Account Connection
Connect-AzAccount

# Assigns the result of deploying a new Azure Resource Group Deployment to the $db variable - deploy cosmos db and key vault
$db = New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateCosmosDB -TemplateParameterFile $TemplateCosmosDBParameters

# Retrieves the value of the 'dbName' parameter from the deployment result
$dbName = $db.Parameters.dbName.Value

# Retrieves the primary keys of the Cosmos DB account using its name and resource group
$cosmosDBKeys = Get-AzCosmosDBAccountKey -ResourceGroupName $ResourceGroupName -Name $dbName
# Retrieves details about the Cosmos DB account using its name and resource group
$cosmosDBAccount = Get-AzCosmosDBAccount -ResourceGroupName $ResourceGroupName -Name $dbName

# Constructs a connection string for the Cosmos DB account using its details
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$($cosmosDBAccount.Name);AccountKey=$($cosmosDBKeys.PrimaryMasterKey);TableEndpoint=https://$($cosmosDBAccount.Name).table.cosmos.azure.com:443/;"

# Executes a JavaScript script named 'createEntities.js' using Node.js and passes the Cosmos DB connection string as an argument
node $CreateEntitiesScript $connectionString

$vaultName = "resumedbkeyvault"
$secretName = "DBCONNECTIONSTRING"
$roleName = "Key Vault Secrets Officer"

# Replace <Your_Username> with your actual username in Azure AD
$username = 'Danijel Črepić'

# Retrieve the user object
$user = Get-AzADUser -DisplayName $username

# Get the Object ID
$objectId = $user.Id

# Display the Object ID
Write-Output "The Object ID for user '$username' is: $objectId"

$subscription = Get-AzSubscription | Where-Object { $_.Name -eq $subscriptionName }
$subscriptionID = $subscription.Id

# Assign role to the user
New-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName $roleName -Scope "/subscriptions/$subscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.KeyVault/vaults/$vaultName"

# Set the secret in Key Vault - add yourself in Azure Key Vault Secrets Officer Role to be able to run this command
Set-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -SecretValue (ConvertTo-SecureString -String $connectionString -AsPlainText -Force)

# deploy storage account, public dns, cdn profile, cdn profile endpoint, function app, hosting plan
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFileStorageCdnProfileDnsZone -TemplateParameterFile $TemplateFileStorageCdnProfileParametersDnsZone

# Enable Static Website on Storage Account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
Enable-AzStorageStaticWebsite -IndexDocument $IndexDocument -ErrorDocument404Path $ErrorDocument -Context $storageAccount.Context

# Set your folder path and container name
$folderPath = "../frontend"
$containerName = '$web'

# Get all files from the folder
$files = Get-ChildItem -Path $folderPath -File

foreach ($file in $files) {
    # Set destination file path (keeping the same folder structure)
    $destinationFileName = Split-Path -Path $file.FullName -Leaf
    $destinationFileName

    # Determine content type based on file extension
    $contentType = @{
        ".html" = "text/html"
        ".css"  = "text/css"
        ".js"   = "text/javascript"
        ".jpg"  = "image/jpg"
        ".png"  = "image/png"
        # Add more file extensions and content types if needed
    }[$file.Extension]
    'Content type' + $contentType

    # Upload file to Azure Blob Storage
    Set-AzStorageBlobContent -Context $storageAccount.Context -Container $containerName -File $file.FullName -Blob $destinationFileName -Properties @{ ContentType = $contentType } -Force
}

# Executes a JavaScript script named 'enablecustomHTTPS.js' using Node.js
node $EnableCustomHTTPSCDNScript $subscriptionID $ResourceGroupName $ProfileName $EndpointName $CustomDomainName
