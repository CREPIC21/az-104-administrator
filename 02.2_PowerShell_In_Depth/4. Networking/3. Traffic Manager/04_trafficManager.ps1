# Define Traffic Manager Profile Details
$TrafficManagerProfileName = "app-profile1000"
$ResourceGroupName = "powershell-grp"

# Create a new Traffic Manager Profile
$TrafficManagerProfile = New-AzTrafficManagerProfile -Name $TrafficManagerProfileName `
    -ResourceGroupName $ResourceGroupName -TrafficRoutingMethod Priority -Ttl 30 `
    -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath "/" -RelativeDnsName "danmantrafficmanager"

# Retrieve Public IP Addresses from the specified Resource Group starting with "app"
$PublicIPAddresses = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName `
| Where-Object { $_.Name -Like "app*" }

$i = 1

# Loop through each retrieved Public IP Address and add them as Traffic Manager endpoints
foreach ($PublicIPAddress in $PublicIPAddresses) {
    Add-AzTrafficManagerEndpointConfig -EndpointName "Endpoint$i" `
        -TrafficManagerProfile $TrafficManagerProfile -Type ExternalEndpoints `
        -Target $PublicIPAddress.IpAddress -EndpointStatus Enabled `
        -Priority $i

    # Update the Traffic Manager Profile with the added endpoint
    Set-AzTrafficManagerProfile -TrafficManagerProfile $TrafficManagerProfile

    $i++
}
