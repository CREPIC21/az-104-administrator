<#
This PowerShell script configures a web infrastructure on Azure. It involves deploying a storage account for hosting a static website, enabling static website functionality on that account, 
uploading necessary website files (HTML, CSS, and JavaScript) to the storage, deploying a CDN (Content Delivery Network) profile, and finally configuring a custom domain for the 
CDN endpoint to make the site accessible through a custom domain name, ensuring efficient content delivery and scalability. Overall, it's a series of steps to create and configure the 
infrastructure required to host a static website and improve its performance using Azure services like Storage and CDN using ARM templates and PowerShell.
#>

# Variables Setup
$ResourceGroupName = "web-grp"
$TemplateFileStorageCdnProfile = ".\storagecdn.json"
$TemplateFileStorageCdnProfileParameters = ".\storagecdn.parameters.json"
$TemplateCosmosDB = ".\cosmosdb.json"
$TemplateCosmosDBParameters = ".\cosmosdb.parameters.json"
$StorageAccountName = "sgdanmansw01"
$IndexDocument = "index.html"
$ErrorDocument = "error.html"
$customDomainName = "mycloudproject.online"

# Azure Account Connection
Connect-AzAccount

# Deploy Storage Account and CDN Profile&Endpoint
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFileStorageCdnProfile -TemplateParameterFile $TemplateFileStorageCdnProfileParameters

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

########################################################## CDN Custom Domain Configuration ########################################################################################################

# Get CDN Profile and CDN Endpoint Objects and Configure Custom Domain
$cdnProfile = Get-AzCdnProfile -ResourceGroupName $ResourceGroupName
$cdnEndpoint = Get-AzCdnEndpoint -ResourceGroupName $ResourceGroupName -ProfileName $cdnProfile.Name

# Add a custom domain (cdnverify cname must be created prior to running this or else it'll error out)
New-AzCdnCustomDomain -EndpointName $cdnEndpoint.Name -HostName $customDomainName -CustomDomainName $customDomainName -ProfileName $cdnProfile.Name -ResourceGroupName $ResourceGroupName

####################################################################################################################################################################################################

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateCosmosDB -TemplateParameterFile $TemplateCosmosDBParameters

$cosmosDBKeys = Get-AzCosmosDBAccountKey -ResourceGroupName $ResourceGroupName -Name 'danmandb'
$cosmosDBAccount = Get-AzCosmosDBAccount -ResourceGroupName $ResourceGroupName -Name 'danmandb'

$connectionString = "DefaultEndpointsProtocol=https;AccountName=$($cosmosDBAccount.Name);AccountKey=$($cosmosDBKeys.PrimaryMasterKey);TableEndpoint=https://danmandb.table.cosmos.azure.com:443/;"

# Execute the JavaScript script using Node.js and pass $c as an argument
node createEntities.js $connectionString

