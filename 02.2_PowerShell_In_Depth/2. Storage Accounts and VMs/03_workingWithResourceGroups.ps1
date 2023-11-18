$ResourceGroupName = "powershell-grp"
$Location = "North Europe"

Remove-AzResourceGroup -Name $ResourceGroupName -Force
'Removed Resource Group ' + $ResourceGroupName

$ResourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

'Provisioning State of resource group: ' + $ResourceGroup.ProvisioningState

$ResourceGroupExisting = Get-AzResourceGroup -Name $ResourceGroupName

$ResourceGroup
$ResourceGroupExisting

$AllResourceGroups = Get-AzResourceGroup
foreach ($Group in $AllResourceGroups) {
    'Removing RG: ' + $Group.ResourceGroupName
    Remove-AzResourceGroup -Name $Group.ResourceGroupName -Force
}
