
$RGName = "bs-resource-group"

Connect-AzAccount

New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile azuredeployment.json -TemplateParameterFile azuredeployment.parameters.json