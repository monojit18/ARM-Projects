param([Parameter(Mandatory=$false)] [string] $rg = "arm-workspace-rg",
      [Parameter(Mandatory=$false)] [string] $fileName = "webapp-deploy.json",
      [Parameter(Mandatory=$false)] [string] $fpath = "/Users/monojitd/Materials/Projects/ARM-Projects/ARM-Templates/WebApp")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/$fileName.json"

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/$fileName.json"
