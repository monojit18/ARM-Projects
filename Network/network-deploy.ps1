param([Parameter(Mandatory=$false)] [string] $rg = "<resource_group>",
        [Parameter(Mandatory=$false)] [string] $fpath = "<fpath>",
        [Parameter(Mandatory=$false)] [string] $vnetName = "<vnet_name>",
        [Parameter(Mandatory=$false)] [string] $vnetPrefix = "<vnet_prefix>",
        [Parameter(Mandatory=$false)] [string] $subnetName = "<subnet_name>",
        [Parameter(Mandatory=$false)] [string] $subnetPrefix = "<subnet_prefix>",
        [Parameter(Mandatory=$false)] [string] $appgwSubnetName = "<appgw_subnet_name>",
        [Parameter(Mandatory=$false)] [string] $appgwSubnetPrefix = "<appgw_subnet_prefix>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/network-deploy.json" `
-vnetName $vnetName -vnetPrefix $vnetPrefix `
-subnetName $subnetName -subnetPrefix $subnetPrefix `
-appgwSubnetName $appgwSubnetName `
-appgwSubnetPrefix $appgwSubnetPrefix

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/network-deploy.json" `
-vnetName $vnetName -vnetPrefix $vnetPrefix `
-subnetName $subnetName -subnetPrefix $subnetPrefix `
-appgwSubnetName $appgwSubnetName `
-appgwSubnetPrefix $appgwSubnetPrefix