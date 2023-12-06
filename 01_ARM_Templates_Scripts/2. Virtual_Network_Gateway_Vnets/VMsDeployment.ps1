
$RGName = "BS-rg"

Connect-AzAccount

New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile CoreVMazuredeploy.json -TemplateParameterFile CoreVMazuredeploy.parameters.json
New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile ManufacturingVMazuredeploy.json -TemplateParameterFile ManufacturingVMazuredeploy.parameters.json