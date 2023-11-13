# Define the geographic location
$location = "North Europe"

# Define the name of the Azure Resource Group
$resourceGroupName = "dan-grp"

# Define the name of the virtual machine
$vmName = "danvm"

# Define the size of the virtual machine
$vmSize = "Standard_DS2_v2"

# Get the credential for the virtual machine (you will be prompted to enter the username and password)
$credential = Get-Credential

# Create a new Azure VM configuration
$vmConfig = New-AzVMConfig -Name $vmName -VMSize $vmSize 

# Set the operating system for the virtual machine to Windows using the specified credentials
Set-AzVMOperatingSystem -VM $vmConfig -ComputerName $vmName -Credential $credential -Windows

# Set the source image for the virtual machine to Windows Server 2022 Datacenter
Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest"

# Define the name of the network interface for the virtual machine
$networkInterfaceName = "dan-interface"

# Get the network interface with the specified name and resource group
$networkInterface = Get-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $resourceGroupName

# Add the network interface to the virtual machine configuration
$Vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $networkInterface.Id

# Disable boot diagnostics for the virtual machine
Set-AzVMBootDiagnostic -Disable -VM $Vm

# Create a new Azure Virtual Machine in the specified resource group and location
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $Vm
