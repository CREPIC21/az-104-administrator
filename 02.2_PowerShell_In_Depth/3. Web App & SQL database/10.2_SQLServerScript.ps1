# List of SQL Server related assemblies to load
$assemblylist =
"Microsoft.SqlServer.Management.Common",  
"Microsoft.SqlServer.Smo",  
"Microsoft.SqlServer.Dmf ",  
"Microsoft.SqlServer.Instapi ",  
"Microsoft.SqlServer.SqlWmiManagement ",  
"Microsoft.SqlServer.ConnectionInfo ",  
"Microsoft.SqlServer.SmoExtended ",  
"Microsoft.SqlServer.SqlTDiagM ",  
"Microsoft.SqlServer.SString ",  
"Microsoft.SqlServer.Management.RegisteredServers ",  
"Microsoft.SqlServer.Management.Sdk.Sfc ",  
"Microsoft.SqlServer.SqlEnum ",  
"Microsoft.SqlServer.RegSvrEnum ",  
"Microsoft.SqlServer.WmiEnum ",  
"Microsoft.SqlServer.ServiceBrokerEnum ",  
"Microsoft.SqlServer.ConnectionInfoExtended ",  
"Microsoft.SqlServer.Management.Collector ",  
"Microsoft.SqlServer.Management.CollectorEnum",  
"Microsoft.SqlServer.Management.Dac",  
"Microsoft.SqlServer.Management.DacEnum",  
"Microsoft.SqlServer.Management.Utility"  
  
# Load SQL Server assemblies
foreach ($asm in $assemblylist) {
    $asm = [Reflection.Assembly]::LoadWithPartialName($asm)
}

# Server configuration: Changing authentication mode and restarting the service
$ServerName = "dbvm"
$SQLServer = New-Object Microsoft.SqlServer.Management.Smo.Server($ServerName)
$SQLServer.Settings.LoginMode = 'Mixed'
$SQLServer.Alter()
Get-Service -Name 'MSSQLSERVER' | Restart-Service -Force

# Creating SQL Server login and assigning sysadmin role
$LoginName = "dbadmin"
$LoginPassword = "Azure@123"

$PasswordSecure = ConvertTo-SecureString -String $LoginPassword -AsPlainText -Force
$DBCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $LoginName, $PasswordSecure

$UserLogin = New-Object Microsoft.SqlServer.Management.Smo.Login($ServerName, $DBCredentials.UserName)
$UserLogin.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$UserLogin.Create($DBCredentials.Password)
$UserLogin.AddToRole("sysadmin")
$UserLogin.Alter()

# Database setup: Changing authentication mode, creating a database, and creating tables
# Installing the SqlServer module
Install-PackageProvider -Name NuGet -Force -Confirm:$False
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module -Name SqlServer -AllowClobber -Confirm:$False

# Creating the database
$DatabaseName = "appdb"
$DBQuery = "CREATE DATABASE appdb"
Invoke-SqlCmd -ServerInstance $ServerName -U $LoginName -p $LoginPassword -Query $DBQuery

# Creating tables by executing SQL script
$ScriptFile = "https://dbstore500098989.blob.core.windows.net/scripts/init.sql"
$Destination = "D:\init.sql"

Invoke-WebRequest -Uri $ScriptFile -OutFile $Destination
Invoke-SqlCmd -ServerInstance $ServerName -InputFile $Destination -Database $DatabaseName -Username $LoginName -Password $LoginPassword

# Opening port 1433 for SQL Server traffic
New-NetFirewallRule -DisplayName "Allow_1433" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow

