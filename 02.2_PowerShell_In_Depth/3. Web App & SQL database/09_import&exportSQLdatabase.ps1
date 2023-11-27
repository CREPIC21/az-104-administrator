# Define Azure resource details
$ResourceGroupName = "powershell-grp"
$AccountKind = "StorageV2"
$AccountSKU = "Standard_LRS"
$Location = "North Europe"
$ContainerName = "sqlbackup"
$AccountName = "danmanstore50009898"

# Create a new Azure Storage Account and Container
$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
    -Name $AccountName -Location $Location -Kind $AccountKind -SkuName $AccountSKU

$Container = New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context `
    -Permission Blob

# Set up database export and storage details
$SourceDatabaseName = "appdb"
$SourceDatabaseServer = "dbserver78e482"
$UserName = "sqladmin"
$Password = "Azure@123"

$PasswordSecure = ConvertTo-SecureString -String $Password -AsPlainText -Force

$blobUri = $Container.CloudBlobContainer.Uri.AbsoluteUri + "/sqlbackup.bacpac"

$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
        -AccountName $AccountName) | Where-Object { $_.KeyName -eq "key1" }

$StorageAccountKeyValue = $StorageAccountKey.Value

# Export the SQL database to Azure Storage
$DatabaseExport = New-AzSqlDatabaseExport -ResourceGroupName $ResourceGroupName `
    -ServerName $SourceDatabaseServer -DatabaseName $SourceDatabaseName `
    -AdministratorLogin $UserName -AdministratorLoginPassword $PasswordSecure `
    -StorageKeyType StorageAccessKey -StorageKey $StorageAccountKeyValue -StorageUri $blobUri

# Check the status of the database export operation
Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $DatabaseExport.OperationStatusLink


# Define target Azure SQL Server and Database details
$TargetLocation = "UK South"
$TargetServerName = "newserver" + (New-Guid).ToString().Substring(1, 6)
$TargetAdminUser = "sqladmin"
$TargetAdminPassword = "Azure@123"
$TargetDatabaseName = "newdb"

$TargetPasswordSecure = ConvertTo-SecureString -String $TargetAdminPassword -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $TargetAdminUser, $TargetPasswordSecure

# Create a new Azure SQL Server and Database
New-AzSQLServer -ResourceGroupName $ResourceGroupName -ServerName $TargetServerName `
    -Location $TargetLocation -SqlAdministratorCredentials $Credential

New-AzSqlDatabase -ResourceGroupName $ResourceGroupName -DatabaseName $TargetDatabaseName `
    -RequestedServiceObjectiveName "S0" -ServerName $TargetServerName

# Retrieve client IP address for firewall rule
$IPAddress = Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content

# Allow client IP address through the firewall
New-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName `
    -ServerName $TargetServerName -FirewallRuleName "Allow-Client" `
    -StartIpAddress $IPAddress.Content -EndIpAddress $IPAddress.Content

# Import the database from Azure Storage to the new Azure SQL Server
$DatabaseImport = New-AzSqlDatabaseImport -DatabaseName $TargetDatabaseName `
    -ServiceObjectiveName "S3" -Edition "Standard" -DatabaseMaxSizeBytes 268435456000 `
    -AdministratorLogin $TargetAdminUser -AdministratorLoginPassword $TargetPasswordSecure `
    -ServerName $TargetServerName -ResourceGroupName $ResourceGroupName `
    -StorageKeyType StorageAccessKey -StorageKey $StorageAccountKeyValue -StorageUri $blobUri

# Check the status of the database import operation
Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $DatabaseImport.OperationStatusLink
