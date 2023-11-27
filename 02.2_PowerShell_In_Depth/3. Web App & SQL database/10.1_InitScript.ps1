# Here we want to ensure that SQLServerScript.ps1 runs as the VM administrator

# Define the URL of the script to be downloaded and its destination path
$ScriptFile = "https://dbstore500098989.blob.core.windows.net/scripts/SQLServerScript.ps1"
$Destination = "D:\SQLServerScript.ps1"

# Download the script from the specified URL to the local destination
Invoke-WebRequest -Uri $ScriptFile -OutFile $Destination

# Define VM credentials and create a PSCredential object
$Domain = "dbvm"
$AdminUser = "sqladmin"
$AdminPassword = "Azure@123"
$credential = New-Object System.Management.Automation.PSCredential @(($Domain + "\" + $AdminUser), (ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))

# Execute the downloaded script on the remote VM using Invoke-Command with specified credentials and computer name
Invoke-Command -FilePath $Destination -Credential $credential -ComputerName $Domain
