param([Parameter(Mandatory=$true)] [string] $rg = "<resource_group>",
      [Parameter(Mandatory=$true)] [string] $fpath = "<fpath>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/storage-deploy.json"

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/storage-deploy.json"
