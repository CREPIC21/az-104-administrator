# Define variables for resource group, locations, network details, etc.
$ResourceGroupName = "powershell-grp"
$Locations = "North Europe", "UK South"
$VirtualNetworkName = "app-network1", "app-network2"
$VirtualNetworkAddressSpace = "10.0.0.0/16", "10.1.0.0/16"
$SubnetName = "SubnetA"
$SubnetAddressSpace = "10.0.0.0/24", "10.1.0.0/24"
$NetworkSecurityGroupName = "app-nsg1", "app-nsg2"
$NetworkInterfaceName = "app-interface"
$i = 1

# Initialize arrays to store virtual networks, network interfaces, etc.
$VirtualNetworks = @()
$NetworkInterfaces = @()
$PublicIPAddresses = @()
$IpConfig = @()
$VmConfig = @()
$VMs = @()

# Credentials for the VMs
$UserName = "demousr"
$Password = "Azure@123"
$PasswordSecure = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $PasswordSecure

# Loop through each location
foreach ($Location in $Locations) {
    # Create subnet configuration for the virtual network
    $Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace[$i - 1] -WarningAction silentlyContinue

    # Create a new virtual network in the specified location
    $VirtualNetworks += New-AzVirtualNetwork -Name $VirtualNetworkName[$i - 1] -ResourceGroupName $ResourceGroupName `
        -Location $Location -AddressPrefix $VirtualNetworkAddressSpace[$i - 1] -Subnet $Subnet

    # Get details of the created virtual network
    Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName[$i - 1]

    # Create a network interface and assign it to the subnet
    $NetworkInterfaces += New-AzNetworkInterface -Name "$NetworkInterfaceName$i" `
        -ResourceGroupName $ResourceGroupName -Location $Location `
        -Subnet $Subnet

    # Create a public IP address and associate it with the network interface
    $PublicIPAddresses += New-AzPublicIpAddress -Name "app-ip$i" -ResourceGroupName $ResourceGroupName `
        -Location $Location -Sku "Standard" -AllocationMethod "Static" -WarningAction silentlyContinue

    # Store IP configurations for the network interfaces
    $IpConfig += Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterfaces[$i - 1]

    # Associate public IP address with the network interface
    $NetworkInterfaces[$i - 1] | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddresses[$i - 1] `
        -Name $IpConfig[$i - 1].Name

    # Apply changes to the network interface
    $NetworkInterfaces[$i - 1] | Set-AzNetworkInterface

    # Create network security rules
    $SecurityRule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
    $SecurityRule2 = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80

    # Create a network security group and associate it with the subnet
    $NetworkSecurityGroup = New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName[$i - 1]  `
        -ResourceGroupName $ResourceGroupName -Location $Location -SecurityRules $SecurityRule1, $SecurityRule2
    Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetworks[$i - 1] `
        -NetworkSecurityGroup $NetworkSecurityGroup -AddressPrefix $SubnetAddressSpace[$i - 1] 
    $VirtualNetworks[$i - 1] | Set-AzVirtualNetwork

    # Create Azure VM configurations
    $NetworkInterfaces[$i - 1] = Get-AzNetworkInterface -Name "$NetworkInterfaceName$i" -ResourceGroupName $ResourceGroupName
    $VmConfig += New-AzVMConfig -Name "$VmName$i" -VMSize $VMSize
    Set-AzVMOperatingSystem -VM $VmConfig[$i - 1] -ComputerName "$VmName$i" -Credential $Credential -Windows
    Set-AzVMSourceImage -VM $VmConfig[$i - 1] -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
    $VMs += Add-AzVMNetworkInterface -VM $VmConfig[$i - 1] -Id $NetworkInterfaces[$i - 1].Id
    Set-AzVMBootDiagnostic -Disable -VM $VMs[$i - 1]
    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMs[$i - 1]

    # Define storage account and blob details for script execution
    $AccountName = "vmstore400089891"
    $ContainerName = "scripts"
    $BlobName = "IIS_Config.ps1"
    $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName
    $Blob = Get-AzStorageBlob -Context $StorageAccount.Context -Container $ContainerName -Blob $BlobName
    $blobUri = @($Blob.ICloudBlob.Uri.AbsoluteUri)
    $StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $AccountName) | Where-Object { $_.KeyName -eq "key1" }

    # Define settings and protected settings for VM extension
    $settings = @{"fileUris" = $blobUri }
    $StorageAccountKeyValue = $StorageAccountKey.Value
    $protectedSettings = @{
        "storageAccountName" = $AccountName
        "storageAccountKey"  = $StorageAccountKeyValue
        "commandToExecute"   = "powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"
    }

    # Set VM extension for executing the script
    Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location -VMName $VMs[$i - 1].Name `
        -Name "IISExtension" -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" `
        -TypeHandlerVersion "1.10" -Settings $settings -ProtectedSettings $protectedSettings

    $i++  # Increment the counter for the next iteration
}
