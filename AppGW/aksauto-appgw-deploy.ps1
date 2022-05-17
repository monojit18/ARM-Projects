param([Parameter(Mandatory=$false)] [string] $rg = "<resource_group>",
        [Parameter(Mandatory=$false)] [string] $fpath = "<fpath>",
        [Parameter(Mandatory=$false)] [string] $applicationGatewayName = "<appgw_name>",
        [Parameter(Mandatory=$false)] [string] $vnetName = "<vnet_name>",
        [Parameter(Mandatory=$false)] [string] $appgwSubnetName = "<appgw_subnet_name>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/aksauto-appgw-deploy.json" `
-TemplateParameterFile "$fpath/AppGW/aksauto-appgw-deploy.parameters.json" `
-applicationGatewayName $applicationGatewayName `
-vnetName $vnetName -subnetName $appgwSubnetName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/aksauto-appgw-deploy.json" `
-TemplateParameterFile "$fpath/AppGW/aksauto-appgw-deploy.parameters.json" `
-applicationGatewayName $applicationGatewayName `
-vnetName $vnetName -subnetName $appgwSubnetName