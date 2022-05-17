param([Parameter(Mandatory=$false)] [string] $rg = "serverless-workshop-rg",
      [Parameter(Mandatory=$false)] [string] $fpath = "<fpath>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/iothub-deploy.json"

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/iothub-deploy.json"
