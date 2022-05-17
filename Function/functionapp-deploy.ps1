param([Parameter(Mandatory=$false)] [string] $rg = "<resource_group>",
      [Parameter(Mandatory=$false)] [string] $fpath = "<fpath>",
      [Parameter(Mandatory=$false)] [string] $appName = "<app_Name>",
      [Parameter(Mandatory=$false)] [string] $storageAccountName = "<storageAccount_Name>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/functionapp-deploy.json" `
-appName $appName -storageAccountName $storageAccountName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/functionapp-deploy.json" `
-appName $appName -storageAccountName $storageAccountName
