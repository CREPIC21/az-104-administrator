<#
This PowerShell script configures a web infrastructure on Azure. It involves deploying a storage account for hosting a static website, enabling static website functionality on that account, 
uploading necessary website files (HTML, CSS, and JavaScript) to the storage, deploying a CDN (Content Delivery Network) profile, and finally configuring a custom domain for the 
CDN endpoint to make the site accessible through a custom domain name, ensuring efficient content delivery and scalability. Overall, it's a series of steps to create and configure the 
infrastructure required to host a static website and improve its performance using Azure services like Storage and CDN using ARM templates and PowerShell.
#>

# Variables Setup
$ResourceGroupName = "web-grp"
$TemplateFileStorageCdnProfileDnsZone = ".\storagecdndnszone.json"
$TemplateFileStorageCdnProfileParametersDnsZone = ".\storagecdndnszone.parameters.json"
$TemplateCosmosDB = ".\cosmosdb.json"
$TemplateCosmosDBParameters = ".\cosmosdb.parameters.json"
$StorageAccountName = "sgdanmansw012"
$IndexDocument = "index.html"
$ErrorDocument = "error.html"

# Azure Account Connection
Connect-AzAccount

# Deploy Storage Account and CDN Profile&Endpoint
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFileStorageCdnProfileDnsZone -TemplateParameterFile $TemplateFileStorageCdnProfileParametersDnsZone

# Enable Static Website on Storage Account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
Enable-AzStorageStaticWebsite -IndexDocument $IndexDocument -ErrorDocument404Path $ErrorDocument -Context $storageAccount.Context

# Get Storage Account Web URL
$weburl = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName | Select-Object PrimaryEndpoints).PrimaryEndpoints.Web
$weburl = $weburl.replace("https://", "")
$weburl = $weburl.replace("/", "")

# Upload Website Files to Storage Account
$websiteFilesArrayOfObjects = @(
    @{
        sourceFile          = "../frontend/index.html";
        destinationFileName = "index.html";
        contentType         = "text/html"
    },
    @{
        sourceFile          = "../frontend/style.css";
        destinationFileName = "style.css";
        contentType         = "text/css"
    },
    @{
        sourceFile          = "../frontend/script.js";
        destinationFileName = "script.js";
        contentType         = "text/javascript"
    }
)
$containerName = '$web'

foreach ($websiteFile in $websiteFilesArrayOfObjects) {
    Set-AzStorageBlobContent -Context $storageAccount.Context -Container $containerName -File $websiteFile.sourceFile -Blob $websiteFile.destinationFileName -Properties @{ ContentType = $websiteFile.contentType }
}

# Assigns the result of deploying a new Azure Resource Group Deployment to the $db variable
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
node createEntities.js $connectionString

