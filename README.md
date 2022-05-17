# Codify Infrastructure on Azure - ARM templates

Let us see how to deploy a **Storage** resource on Azure. <br>But before delving into this, let us have a look at the high level view of the ARM components:

![](./Assets/ARM-basic.png)



## Blob Storage

### Parameters

- **storageAccountName** - The Account name for the Storage account - *type String*
- **blobContainers** - The list of Blob containers to be created - *type array*
- **location** - Geo Location of the Blob Storage account - *type string*

```j
"parameters": {
      "storageAccountName": {
        "type": "string",
        "defaultValue": "appsvcstrg"
      },
      "blobContainers": {
        "type": "array",
        "defaultValue": [
          "logblob",
          "cacheblob"
        ]
    },
      "location": {
        "type": "string",
        "defaultValue": "[resourceGroup().location]"
    }
}
```

### Resources

The resources and sub-resources to be created in the process of creating the Blob Storage

```
"resources": []
```

This is an array of JSON objects depicting various azure resources to be deployed

### Storage Account

```J
{
    "name": "[parameters('storageAccountName')]",
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "2019-06-01",
    "location": "[parameters('location')]",
    "kind": "StorageV2",
    "sku": {
      "name": "Standard_LRS",
      "tier": "Standard"
    },
    "properties": {
      "accessTier": "Cool"
    }            
}
```

This creates/deploys a Storage account of type *Standard_LRS* and *Cool* access tier

### Blob Containers

```J
{
  "type": "Microsoft.Storage/storageAccounts/blobServices/containers",
  "apiVersion": "2019-06-01",
  "name": "[concat(parameters('storageAccountName'), '/default/', parameters('blobContainers')[copyIndex()])]",
  "copy": {
    "name": "containercopy",
    "count": "[length(parameters('blobContainers'))]"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName'))]"
  ]
}
```

This creates/deploys a list of containers into the account created at ***StorageAccount***

The complete *resources* section below:

```J
"resources": [
  {
    "name": "[parameters('storageAccountName')]",
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "2019-06-01",
    "location": "[parameters('location')]",
    "kind": "StorageV2",
    "sku": {
      "name": "Standard_LRS",
      "tier": "Standard"
    },
    "properties": {
      "accessTier": "Cool"
    }            
  },
  {
    "type": "Microsoft.Storage/storageAccounts/blobServices/containers",
    "apiVersion": "2019-06-01",
    "name": "[concat(parameters('storageAccountName'), '/default/', parameters('blobContainers')[copyIndex()])]",
    "copy": {
      "name": "containercopy",
      "count": "[length(parameters('blobContainers'))]"
    },
    "dependsOn": [
      "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName'))]"
    ]
  }
]
```

The most noticeable part of this section is the ***copyIndex()*** call; this is how ARM template implement loops - here ***parameters('blobContainers')*** is a list in the parameters section - ***["logblob","cacheblob"].*** 

In the resources section, as shown above, *copy* section will run through the loop, pick up *blob Container name(s)* and append it to the rest of the values in *name* section:

```J
"name": "[concat(parameters('storageAccountName'), '/default/', parameters('blobContainers')[copyIndex()])]"
```

### How to Deploy?

This is achieved using PowerShell. (*The examples here uses PowerShellCore version 7.2; should work with Windows PowerShell also!*) 

```powershell
param([Parameter(Mandatory=$true)] [string] $rg = "<resource_group>",
      [Parameter(Mandatory=$true)] [string] $fpath = "<fpath>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/storage-deploy.json"

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/storage-deploy.json"
```

In this case almost all variables are with default values within the ARM template json file. But those values can be overridden here -

```powershell
New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/storage-deploy.json" `
-<parameter_Name> <parameter_value>
```





## ACR - Azure Container Registry

### Parameters

- **acrName** - Name of the ACR resource;  *The **registry name** must be unique within **Azure**, and contain 5-50 alphanumeric characters* - *type string*

- **acrAdminUserEnabled** - whether ACR is Admin enabled with access credentials. Ideally it should be set to NO. A ***Service Principal*** should be created with ACR access and to be shared securely with designated user(s)/service(s) only to access ACR.

  Best practice is to allow some service(s) like *DevOps* to allow access to this *Service Principal* and hence to the ACR resource - *type bool*

- **location** - Geo Location of the resource  - *type string*

- **acrSku** - The Tier - *Standard* or *Premium*  - *type string*

### Variables

- **loginServer** - Convenience variable to be used later in the *resource* section

### Resources

```
{
  "name": "[parameters('acrName')]",
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2019-05-01",
  "location": "[parameters('location')]",
  "comments": "Container registry for storing docker images",
  "tags": {
    "displayName": "Container Registry",
    "container.registry": "[parameters('acrName')]"
  },
  "sku": {
    "name": "[parameters('acrSku')]",
    "tier": "[parameters('acrSku')]"
  },
  "properties": {
	  "adminUserEnabled": "[parameters('acrAdminUserEnabled')]"
  }
}
```



### Outputs

- **acrLoginServer** - This is what the deployment process would export after the ACR resource is created on Azure.Calling scripts can use this value to process further like save it in-memory variables or in KeyVault and use it at a late step; e.g. long ad complicated ***automated*** setup  processes like *AKS (Azure Kubernetes Service)*

### How to Deploy?

This is achieved using PowerShell. (*The examples here uses PowerShellCore version 7.2; should work with Windows PowerShell also!*)

```powershell
param([Parameter(Mandatory=$false)] [string] $rg = "<resource_group>",
        [Parameter(Mandatory=$false)] [string] $fpath = "<fpath>",
        [Parameter(Mandatory=$false)] [string] $acrName = "<acr_name>")

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/aksauto-acr-deploy.json" `
-acrName $acrName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/aksauto-acr-deploy.json" `
-acrName $acrName

```



## Virtual Network

### Parameters

- **vnetName** - Name of the Virtual Network  - *type string*
- **vnetPrefix** - The Address space for VNET  - *type string*
- **subnetName** - Name of the Subnet under the above Virtual Network  - *type string*
- **subnetPrefix** - The Address space for Subnet  - *type string*
- **appgwSubnetName** - Name of the another Subnet under the above Virtual Network  - *type string*
- **appgwSubnetPrefix** - The Address space for AppGw Subnet  - *type string*
- **location** - Geo Location of the resource  - *type string*

### Resources

The resources to be deployed onto Azure -

1. #### The parent Virtual Network

```
"apiVersion": "2018-10-01",
"type": "Microsoft.Network/virtualNetworks",
"name": "[parameters('vnetName')]",
"location": "[parameters('location')]",
"properties": {
  "addressSpace": {
      "addressPrefixes": [
      "[parameters('vnetPrefix')]"
    ]
  }
}
```

2. The First Subnet under the parent VNET

```
{
    "apiVersion": "2018-10-01",
    "type": "subnets",
    "location": "[parameters('location')]",
    "name": "[parameters('subnetName')]",
    "dependsOn": [
      "[parameters('vnetName')]"
    ],
    "properties": {
      "addressPrefix": "[parameters('subnetPrefix')]"
    }
}
```

3. The Second Subnet under the parent VNET

```
{
    "apiVersion": "2018-10-01",
    "type": "subnets",
    "location": "[parameters('location')]",
    "name": "[parameters('appgwSubnetName')]",
    "dependsOn": [
      "[parameters('vnetName')]",
      "[parameters('subnetName')]"
    ],
    "properties": {
      "addressPrefix": "[parameters('appgwSubnetPrefix')]"
    }
}
```

Notice the ***dependsOn*** section - the *appgwSubnetName* is dependent on the creation of the vnet as well as the first subnet. This is important as the address space is properly distributed else Azure Resource Manager would complain and fail the deployment!

So the complete resources section would like -

```
"resources": [
  {
    "apiVersion": "2018-10-01",
    "type": "Microsoft.Network/virtualNetworks",
    "name": "[parameters('vnetName')]",
    "location": "[parameters('location')]",
    "properties": {
      "addressSpace": {
        "addressPrefixes": [
          "[parameters('vnetPrefix')]"
        ]
      }
    },
    "resources": [
      {
        "apiVersion": "2018-10-01",
        "type": "subnets",
        "location": "[parameters('location')]",
        "name": "[parameters('subnetName')]",
        "dependsOn": [
          "[parameters('vnetName')]"
        ],
        "properties": {
          "addressPrefix": "[parameters('subnetPrefix')]"
        }
      },          
      {
        "apiVersion": "2018-10-01",
        "type": "subnets",
        "location": "[parameters('location')]",
        "name": "[parameters('appgwSubnetName')]",
        "dependsOn": [
          "[parameters('vnetName')]",
          "[parameters('subnetName')]"
        ],
        "properties": {
          "addressPrefix": "[parameters('appgwSubnetPrefix')]"
        }
      }
    ]
  }
]
```

Noticeable section is ***resources:[]*** inside the parent section of ***resources:[]***. This is how sub-resources in ARM template is implemented. so, all dependent resources are going inside the child ***resources:[]*** section with their respective ***dependenOn*** property defined e..g *subnet0* is dependant on the parent VNET to be created first and *subnet1* is dependent on both parent VNET and *subnet0* to created successfully. Azure Resource Manage would basically sequence the calls accordingly!

### How to Deploy?

This is achieved using PowerShell. (*The examples here uses PowerShellCore version 7.2; should work with Windows PowerShell also!*)

```powershell
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
```

#### **Refs**:

- ***ARM Template documentation*** - https://docs.microsoft.com/en-us/azure/azure-resource-manager/

- **Storage Account** - https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts

- **Container Registry** - https://docs.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries

- **Virtual Network** - https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks

- **Source Code** - https://github.com/monojit18/ARM-Templates

  

