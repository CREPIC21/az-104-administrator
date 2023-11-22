param(
    [Parameter(Mandatory = $true)]
    [string]$Environment
)

# Read and parse JSON content from the specified file into an object
$object = Get-Content -Raw -Path "38_definingConfigFile.json" | ConvertFrom-Json

# Initialize variables to store virtual network and subnet details
$virtualNetworkName = $null
$virtualNetworAddressSpace = $null
$subnetNames = @()
$subnetIPAddressSpace = @()

# Switch based on the provided environment to gather configuration details
switch ($Environment) {
    "Development" {
        $virtualNetworkName = $Object.Development.VirtualNetwork.Name
        $virtualNetworAddressSpace = $Object.Development.VirtualNetwork.AddressSpace
        $subnetNames += $Object.Development.Subnets.Name
        $subnetIPAddressSpace += $Object.Development.Subnets.AddressSpace
    }
    "Staging" {
        $virtualNetworkName = $Object.Staging.VirtualNetwork.Name
        $virtualNetworAddressSpace = $Object.Staging.VirtualNetwork.AddressSpace
        $subnetNames += $Object.Staging.Subnets.Name
        $subnetIPAddressSpace += $Object.Staging.Subnets.AddressSpace
    }
}

# Create subnet configurations based on retrieved details
$subnetConfigs = @()
$count = $subnetNames.Count
for ($i = 0; $i -lt $count; $i++) {
    $subnetConfigs += New-AzVirtualNetworkSubnetConfig -Name $subnetNames[$i] -AddressPrefix $subnetIPAddressSpace[$i]
}

# Define the Azure Resource Group name and location
$resourceGroup = "powershell-grp"
$location = "North Europe"

# Create a new Azure Virtual Network based on the gathered configuration
New-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroup -Location $location -AddressPrefix $virtualNetworAddressSpace -Subnet $subnetConfigs
