# Define an array of network names
$NetworkNames = "staging-network", "test-network"

# Initialize an empty hashtable to store virtual networks
$VirtualNetworks = @{}

# Loop through each network name and retrieve corresponding virtual network details
foreach ($NetworkName in $NetworkNames) {
    $VirtualNetworks.Add($NetworkName, (Get-AzVirtualNetwork -Name $NetworkName))
}

# Create a peering connection from "staging-network" to "test-network"
Add-AzVirtualNetworkPeering `
    -Name "Staging-Test" `
    -VirtualNetwork $VirtualNetworks["staging-network"] `
    -RemoteVirtualNetworkId $VirtualNetworks["test-network"].Id

# Create a peering connection from "test-network" to "staging-network"
Add-AzVirtualNetworkPeering `
    -Name "Test-Staging" `
    -VirtualNetwork $VirtualNetworks["test-network"] `
    -RemoteVirtualNetworkId $VirtualNetworks["staging-network"].Id
