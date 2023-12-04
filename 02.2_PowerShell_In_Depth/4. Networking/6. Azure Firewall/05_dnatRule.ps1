# Define Firewall Policy and Resource Group details
$FirewallPolicyName = "firewall-policy"
$ResourceGroupName = "powershell-grp"

# Define details for the Public IP of the firewall
$PublicIPDetails = @{
    Name              = 'firewall-ip'
    Location          = $Location
    Sku               = 'Standard'
    AllocationMethod  = 'Static'
    ResourceGroupName = $ResourceGroupName
}

# Create a Rule Collection Group for NAT rules in the Firewall Policy
$CollectionGroup = New-AzFirewallPolicyRuleCollectionGroup -Name "NATCollectionGroup" -Priority 200 `
    -ResourceGroupName $ResourceGroupName -FirewallPolicyName $FirewallPolicyName

# Fetching details to set up a NAT rule for RDP access
$VmName = "appvm"
$NATRuleName = "Allow-RDP-$VmName"
$MyIPAddress = Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content

# Retrieve IP information for the VM and Firewall
$FirewallPublicIPAddress = (Get-AzPublicIpAddress -Name $PublicIPDetails.Name).IpAddress
$VMNetworkProfile = (Get-AzVm -Name $VmName).NetworkProfile
$NetworkInterface = Get-AzNetworkInterface -ResourceId $VMNetworkProfile.NetworkInterfaces[0].Id
$VMPrivateIPAddress = $NetworkInterface.IpConfigurations[0].PrivateIpAddress

# Create a NAT rule for allowing RDP traffic
$Rule1 = New-AzFirewallPolicyNatRule -Name $NATRuleName -Protocol "TCP" -SourceAddress $MyIPAddress.Content `
    -DestinationAddress $FirewallPublicIPAddress -DestinationPort "4000" `
    -TranslatedAddress $VMPrivateIPAddress -TranslatedPort "3389"

# Create a rule collection in the NAT collection group
$Collection = New-AzFirewallPolicyNatRuleCollection -Name "CollectionA" -Priority 1000 -Rule $Rule1 `
    -ActionType "Dnat"

# Retrieve the existing NAT collection group
$CollectionGroup = Get-AzFirewallPolicyRuleCollectionGroup -Name "NATCollectionGroup" `
    -ResourceGroupName $ResourceGroupName -AzureFirewallPolicyName $FirewallPolicyName

# Add the newly created rule collection to the existing NAT collection group
$CollectionGroup.Properties.RuleCollection.Add($Collection)

# Get the Firewall Policy
$FirewallPolicy = Get-AzFirewallPolicy -Name $FirewallPolicyName -ResourceGroupName $ResourceGroupName

# Update the NAT collection group in the Firewall Policy with the added rule collection
Set-AzFirewallPolicyRuleCollectionGroup -Name "NATCollectionGroup" -Priority 200 `
    -FirewallPolicyObject $FirewallPolicy -RuleCollection $CollectionGroup.Properties.RuleCollection
