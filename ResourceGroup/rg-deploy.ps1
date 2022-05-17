param([Parameter(Mandatory=$false)] [string] $rg = "<resource_group>",
        [Parameter(Mandatory=$false)] [string] $fpath = "<fpath>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/rg-deploy.json"

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/rg-deploy.json"