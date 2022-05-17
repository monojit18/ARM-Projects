param appName string
param skuName string
param skuTier string
param storageAccountName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_RAGRS'
param location string = resourceGroup().location

@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'

@maxLength(4)
param environments array = [
  'Dev'
]

var functionAppName_var = appName
var applicationInsightsName_var = '${appName}-insights'
var hostingPlanName_var = '${appName}-plan'
var storageAccountId = '${resourceGroup().id}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'
var functionWorkerRuntime = runtime

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
  properties: {
    accessTier: 'Cool'
  }
}


resource hostingPlanName 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: hostingPlanName_var
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties:{}
}

resource functionAppName 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName_var
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlanName.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountId, '2015-05-01-preview').key1}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountId, '2015-05-01-preview').key1}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(applicationInsightsName.id, '2015-05-01').InstrumentationKey
        }
      ]
    }
  }
  dependsOn: [
    storageAccountName_resource
  ]
}

resource functionAppName_environments 'Microsoft.Web/sites/slots@2021-02-01' = [for item in environments: {
  name: '${functionAppName_var}/${item}'
  kind: 'functionapp'
  location: location
  properties: {
    serverFarmId: hostingPlanName.id
  }
  dependsOn: [
    functionAppName
  ]
}]

resource applicationInsightsName 'microsoft.insights/components@2015-05-01' = {
  name: applicationInsightsName_var
  kind: 'web'
  location: location
  tags: {
    'hidden-link:${resourceGroup().id}/providers/Microsoft.Web/sites/${applicationInsightsName_var}': 'Resource'
  }
  properties:{
    Application_Type: 'web'
  }
}

