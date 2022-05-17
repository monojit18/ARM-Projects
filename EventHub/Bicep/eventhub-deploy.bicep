param eventHubNamespaceName string
param skuName string

param authRulesSendAndListen array = [
  'Send'
  'Listen'
]

param authRulesDefault array = [
  'Manage'
  'Send'
  'Listen'
]

param defaultAuthRuleName string = 'RootManageSharedAccessKey'
param isAutoInflateEnabled bool = true

@minValue(0)
@maxValue(20)
param maximumThroughputUnits int = 10
param ocrEventHubName string
param iotEventHubName string

@minValue(1)
@maxValue(7)
param messageRetentionInDays int = 1

@minValue(2)
@maxValue(32)
param partitionCount int = 4
param location string = resourceGroup().location

var authRuleResourceId = resourceId('Microsoft.EventHub/namespaces/authorizationRules', eventHubNamespaceName, defaultAuthRuleName)

var ocrEventHubAuthRuleName = '${ocrEventHubName}-sendandlisten-rule'
var ocrAuthRuleResourceId = resourceId('Microsoft.EventHub/namespaces/eventhubs/authorizationRules', eventHubNamespaceName, ocrEventHubName, ocrEventHubAuthRuleName)

var iotEventHubAuthRuleName = '${iotEventHubName}-sendandlisten-rule'
var iotAuthRuleResourceId = resourceId('Microsoft.EventHub/namespaces/eventhubs/authorizationRules', eventHubNamespaceName, iotEventHubName, iotEventHubAuthRuleName)

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-01-01-preview' = {

  name: eventHubNamespaceName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    isAutoInflateEnabled: isAutoInflateEnabled
    maximumThroughputUnits: maximumThroughputUnits
  }

  resource eventHubNamespaceAuthRule 'AuthorizationRules@2021-01-01-preview' = {

    name: defaultAuthRuleName
    properties: {
      rights: authRulesDefault
    }
  }
}

resource ocrEventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-01-01-preview' = {

  parent: eventHubNamespace
  name: ocrEventHubName
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
  }

  resource eventhubAuthRule 'authorizationRules@2021-01-01-preview' = {

    name: ocrEventHubAuthRuleName
    properties: {
      rights: authRulesSendAndListen
    }
  }

  resource ocrEventHubConsumerGroup 'consumergroups@2021-01-01-preview' = [for i in range(1, 2): {

    name: '${ocrEventHubName}-consumer-group-${i}'
  }]
}

resource iotEventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-01-01-preview' = {

  parent: eventHubNamespace
  name: iotEventHubName
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
  }

  resource eventhubAuthRule 'authorizationRules@2021-01-01-preview' = {

    name: iotEventHubAuthRuleName
    properties: {
      rights: authRulesSendAndListen
    }
  }

  resource iotEventHubConsumerGroup 'consumergroups@2021-01-01-preview' = [for i in range(1, 1): {

    name: '${iotEventHubName}-consumer-group-${i}'
  }]
}

output eventHubNamespacePrimaryConnectionString string = listkeys(authRuleResourceId, '2021-01-01-preview').primaryConnectionString
output eventHubNamespacePrimaryKey string = listkeys(authRuleResourceId, '2021-01-01-preview').primaryKey

output ocrEventHubConnectionString string = listkeys(ocrAuthRuleResourceId, '2021-01-01-preview').primaryConnectionString
output ocrEventHubPrimaryKey string = listkeys(ocrAuthRuleResourceId, '2021-01-01-preview').primaryKey

output iotEventHubConnectionString string = listkeys(iotAuthRuleResourceId, '2021-01-01-preview').primaryConnectionString
output iotEventHubPrimaryKey string = listkeys(iotAuthRuleResourceId, '2021-01-01-preview').primaryKey
