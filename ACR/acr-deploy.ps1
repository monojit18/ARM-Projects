param([Parameter(Mandatory=$false)] [string] $rg = "<resource_group>",
        [Parameter(Mandatory=$false)] [string] $fpath = "<fpath>",
        [Parameter(Mandatory=$false)] [string] $acrName = "<acr_name>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/aksauto-acr-deploy.json" `
-acrName $acrName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/aksauto-acr-deploy.json" `
-acrName $acrName
