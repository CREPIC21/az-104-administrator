# Resource Group and DNS Zone Details
$ResourceGroupName = "powershell-grp"
$DNSZoneName = "auctiondanman.xyz"

# Create a new DNS Zone
$DNSZone = New-AzDnsZone -Name $DNSZoneName -ResourceGroupName $ResourceGroupName

# Retrieve and display the Name Servers for the created DNS Zone
foreach ($NameServer in $DNSZone.NameServers) {
    $NameServer
}

# Load Balancer Details
$LoadBalancerName = "app-balancer"
$LoadBalancer = Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName

# Retrieve Public IP Address ID from the Load Balancer
$PublicIPAddressId = $LoadBalancer.FrontendIpConfigurations[0].PublicIpAddress.Id

# Retrieve Public IP Address Object using the Resource ID
$PublicIPAddressObj = Get-AzResource -ResourceId $PublicIPAddressId

# Get Public IP Address details
$PublicIPAddress = Get-AzPublicIpAddress -Name $PublicIPAddressObj.Name

# Create a new DNS Record Set for 'www' pointing to the Public IP Address of the Load Balancer
New-AzDnsRecordSet -Name www -RecordType A -ZoneName $DNSZoneName `
    -ResourceGroupName $ResourceGroupName -Ttl 3600 `
    -DnsRecords (New-AzDnsRecordConfig -Ipv4Address $PublicIPAddress.IpAddress)
