# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define names for source and target databases, SQL server, and restoration point time
$serverName = "dbserver9f3293"
$sourcedatabaseName = "appdb"
$targetDatabaseName = "restored-db"
$restorePointTime = (Get-Date).AddMinutes(-30)

# Retrieve the specified database details
$database = Get-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $sourcedatabaseName

# Restore a SQL database to a specific point in time using Azure PowerShell
Restore-AzSqlDatabase -FromPointInTimeBackup -PointInTime $restorePointTime -ResourceGroupName $resourceGroup -ServerName $serverName `
    -TargetDatabaseName $targetDatabaseName -ResourceId $database.ResourceId -Edition "Standard" -ServiceObjectiveName "S0"
