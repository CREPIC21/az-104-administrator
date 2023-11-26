# Define the Azure Resource Group name
$resourceGroup = "powershell-grp"

# Define the geographic location
$location = "North Europe"

# Generate a unique server name and set credentials for the SQL Server admin
$serverName = "dbserver" + (New-Guid).ToString().Substring(1, 6)
$adminUser = "sqladmin"
$adminPassword = "Azure@123"

# Convert the admin password to a secure string
$passwordSecure = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUser, $passwordSecure

# Create a new SQL Server with specified credentials
New-AzSqlServer -ResourceGroupName $resourceGroup -ServerName $serverName -Location $location -SqlAdministratorCredentials $credentials

# Define the name for the SQL database
$databaseName = "appdb"

# Create a new SQL Database within the created SQL Server
New-AzSqlDatabase -ResourceGroupName $resourceGroup -DatabaseName $databaseName -RequestedServiceObjectiveName "S0" -ServerName $serverName

# Retrieve the public IP address of the current machine
$myIPAddress = Invoke-WebRequest -Uri "https://ifconfig.me/ip" | Select-Object Content

# Allow access to the SQL Server firewall from the current machine's IP address
New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroup -ServerName $serverName -FirewallRuleName "Allow My IP" -StartIpAddress $myIPAddress.Content -EndIpAddress $myIPAddress.Content

# Initialize variables for server FQDN and full server name
$serverFQDN = $null
$fullServerName = $null

# Retrieve SQL Servers within the resource group and gather details for a specific server
$SQLServers = Get-AzSqlServer -ResourceGroupName $resourceGroup

foreach ($sqlServer in $SQLServers) {
    if ($sqlServer.ServerName.Contains("dbserver")) {
        $serverFQDN = $sqlServer.FullyQualifiedDomainName
        $fullServerName = $sqlServer.ServerName
        'The Servers FQDN is: ' + $serverFQDN
        'The Servers name is: ' + $fullServerName
    }
}

# Define the SQL script file to execute
$scriptFile = "07_00.sql"

# Execute the SQL script against the specified SQL Server and database
Invoke-SqlCmd -ServerInstance $serverFQDN -Database $databaseName -Username $adminUser -Password $adminPassword -InputFile $scriptFile

# Define the name for the Log Analytics workspace
$workspaceName = "dbworkspace4321"

# Create a Log Analytics workspace in the specified location and resource group
$logAnalyticsWorkspace = New-AzOperationalInsightsWorkspace -Location $location -Name $workspaceName -ResourceGroupName $resourceGroup

# Enable SQL database auditing to log analytics workspace
Set-AzSqlDatabaseAudit -ResourceGroupName $resourceGroup -ServerName $fullServerName -DatabaseName $databaseName -LogAnalyticsTargetState Enabled -WorkspaceResourceId $logAnalyticsWorkspace.ResourceId
