# Define Azure Resource Group and Location details
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"

# Create Public IP for the Load Balancer
$PublicIPDetails = @{
    Name              = 'load-ip'
    Location          = $Location
    Sku               = 'Standard'
    AllocationMethod  = 'Static'
    ResourceGroupName = $ResourceGroupName
}
$PublicIP = New-AzPublicIpAddress @PublicIPDetails

# Define and configure Frontend IP configuration for the Load Balancer
$FrontEndIP = New-AzLoadBalancerFrontendIpConfig -Name "load-frontendip" `
    -PublicIpAddress $PublicIP

# Create the Load Balancer
$LoadBalancerName = "app-balancer"
New-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName `
    -Location $Location -Sku "Standard" -FrontendIpConfiguration $FrontEndIP

# Get Load Balancer and configure Backend Address Pool
$LoadBalancer = Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName
$LoadBalancer | Add-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool"
$LoadBalancer | Set-AzLoadBalancer

# Retrieve Network Interfaces and associate them with the Load Balancer Backend Address Pool
$NetworkInterfaces = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName `
| Where-Object { $_.Name -Like "app-interface*" }

$BackendAddressPool = Get-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool" `
    -LoadBalancer $LoadBalancer

foreach ($NetworkInterface in $NetworkInterfaces) {
    $NetworkInterface.IpConfigurations[0].LoadBalancerBackendAddressPools = $BackendAddressPool
    $NetworkInterface | Set-AzNetworkInterface    
}

# Configure Load Balancer Health Probe
$LoadBalancer | Add-AzLoadBalancerProbeConfig -Name "ProbeA" -Protocol "tcp" -Port "80" `
    -IntervalInSeconds "10" -ProbeCount "2"
$LoadBalancer | Set-AzLoadBalancer

# Define Load Balancer Rule and associate it with Backend Address Pool and Probe
$Probe = Get-AzLoadBalancerProbeConfig -Name "ProbeA" -LoadBalancer $LoadBalancer

$LoadBalancer | Add-AzLoadBalancerRuleConfig -Name "RuleA" -FrontendIpConfiguration $LoadBalancer.FrontendIpConfigurations[0] `
    -Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -BackendAddressPool $BackendAddressPool `
    -Probe $Probe

$LoadBalancer | Set-AzLoadBalancer
