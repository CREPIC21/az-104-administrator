# Import the Server Manager module to manage Windows Server roles and features
import-module servermanager

# Install the Web Server (IIS) role with all its subfeatures
add-windowsfeature web-server -includeallsubfeature

# Install ASP.NET 4.5 under the Web Server role
add-windowsfeature Web-Asp-Net45

# Install .NET Framework Features
add-windowsfeature NET-Framework-Features

# Set the content of the Default.html file in the wwwroot directory with a message including the server's computer name
Set-Content -Path "C:\inetpub\wwwroot\Default.html" -Value "This is the server $($env:computername)"
