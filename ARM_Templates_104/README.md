- PowerShell login to Azure
```PowerShell
Connect-AzAccount
```

- PowerShell deployment
```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName app-grp -TemplateFile template01.json
```

- PowerShell deployment with parameters
```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName app-grp -TemplateFile template09.json -resourceLocation "UK South"
```

- PowerShell deployment with parameters file
```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName app-grp -TemplateFile template10.json -TemplateParameterFile template10.parameters.json
```