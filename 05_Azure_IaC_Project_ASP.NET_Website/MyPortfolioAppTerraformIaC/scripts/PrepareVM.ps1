# Install IIS (with Management Console)
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Install Web Management Service
Install-WindowsFeature -Name Web-Mgmt-Service

# Install ASP.NET Hosting Bundle (replace the URL with the latest version)
$aspNetHostingBundleUrl = "https://download.visualstudio.microsoft.com/download/pr/d7124775-38c9-460f-a269-7bc131b3dfbf/7f60bcc6030e408cf11a935d5451ffa4/dotnet-hosting-6.0.20-win.exe"
$aspNetHostingBundlePath = "D:\dotnet-hosting-6.0.0-win.exe"
Invoke-WebRequest -Uri $aspNetHostingBundleUrl -OutFile $aspNetHostingBundlePath
Start-Process -FilePath $aspNetHostingBundlePath -ArgumentList "/install", "/quiet" -Wait

# Install Web Deploy 3.6 (replace the URL with the latest version)
$webDeployUrl = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
$webDeployPath = "D:\webdeploy_amd64_en-US.msi"
Invoke-WebRequest -Uri $webDeployUrl -OutFile $webDeployPath
$installationType = "Complete"
# Install Web Deploy with the chosen installation type
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $webDeployPath, "/qn", "ADDLOCAL=ALL", "CUSTOM_SETUP=$installationType" -Wait