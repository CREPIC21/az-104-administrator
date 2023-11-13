param (
    [string]$db_username,
    [string]$db_password
)

$LoginName = $db_username
$LoginPassword = $db_password
$DatabaseName = "appdb"
$ServerName = "db-vm"
$DBQuery = "CREATE DATABASE appdb"


Invoke-SqlCmd -ServerInstance $ServerName -U $LoginName -p $LoginPassword -Query $DBQuery

$LoginName = $db_username
$LoginPassword = $db_password
$ServerName = "db-vm"
$DatabaseName = "appdb"
$ScriptFile = "https://${storage_account_name}.blob.core.windows.net/${container_name}/01.sql"
$Destination = "D:\01.sql"


Invoke-WebRequest -Uri $ScriptFile -OutFile $Destination
Invoke-SqlCmd -ServerInstance $ServerName -InputFile $Destination -Database $DatabaseName -U $LoginName -P $LoginPassword


