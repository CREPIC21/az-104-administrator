<#
This PowerShell script configures a web infrastructure on Azure. It involves deploying a storage account for hosting a static website, enabling static website functionality on that account, 
uploading necessary website files (HTML, CSS, and JavaScript) to the storage, deploying a CDN (Content Delivery Network) profile, and finally configuring a custom domain for the 
CDN endpoint to make the site accessible through a custom domain name, ensuring efficient content delivery and scalability. Overall, it's a series of steps to create and configure the 
infrastructure required to host a static website and improve its performance using Azure services like Storage and CDN using ARM templates and PowerShell.
#>

# Variables Setup
$ResourceGroupName = "web-grp"
$TemplateFileStorageAccount = ".\storageAccount.json"
$TemplateFileCdnProfile = ".\cdnProfile.json"
$StorageAccountName = "0staticsitedanman0011223"
$IndexDocument = "index.html"
$ErrorDocument = "error.html"
$customDomainName = "projectdanijel.online"

# Azure Account Connection
Connect-AzAccount

# Deploy Storage Account
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFileStorageAccount

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

# Deploy CDN Profile
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFileCdnProfile

# Get CDN Profile and CDN Endpoint Objects and Ci=onfigure Custom Domain
$cdnProfile = Get-AzCdnProfile -ResourceGroupName $ResourceGroupName
$cdnEndpoint = Get-AzCdnEndpoint -ResourceGroupName $ResourceGroupName -ProfileName $cdnProfile.Name

New-AzCdnCustomDomain -EndpointName $cdnEndpoint.Name -HostName $customDomainName -CustomDomainName $customDomainName -ProfileName $cdnProfile.Name -ResourceGroupName $ResourceGroupName