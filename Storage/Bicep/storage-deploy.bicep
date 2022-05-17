param storageAccountName string
param blobContainers array
param queues array
param location string = resourceGroup().location

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
  }
}

resource storageAccountName_default_blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = [for blob in blobContainers: {
  name: '${storageAccountName}/default/${blob}'
  dependsOn: [
    storageAccountName_resource
  ]
}]

resource storageAccountName_default_queueContainers 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-02-01' = [for queue in queues: {
  name: '${storageAccountName}/default/${queue}'
  dependsOn: [
    storageAccountName_resource
  ]
}]
