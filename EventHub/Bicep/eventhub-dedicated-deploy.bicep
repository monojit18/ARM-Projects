param clusterName string
param dedicatedEventHubNamespaceName string
param skuName string
param dedicatedEventHubName string
param location string = resourceGroup().location

resource dedicatedEventHubCluster 'Microsoft.EventHub/clusters@2018-01-01-preview' = {

  name: clusterName
  location: location
  sku: {
    name: 'Dedicated'
    capacity: 4
  }
}

resource dedicatedEventHubNamespace 'Microsoft.EventHub/namespaces@2021-01-01-preview' = {

  name: dedicatedEventHubNamespaceName
  location: location
  sku: {
    name: skuName
    tier: skuName
    capacity: 4
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 0
    clusterArmId: dedicatedEventHubCluster.id
  }
}

resource dedicatedEventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-01-01-preview' = {

  parent: dedicatedEventHubNamespace
  name: dedicatedEventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 10
  }
}
