param serviceBusNamespaceName string
param tweetServiceBusQueueName string
param OcrServiceBusTopicName string
param nextHopServiceBusTopicName string
param ocrServiceBusSubscriptionName string
param nextHopServiceBusSubscriptionName string
param authRulesListen array = [
  'Listen'
]

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

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sbSku string = 'Standard'
param location string = resourceGroup().location

var serviceBusNamespaceAuthRuleId = resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', serviceBusNamespaceName, defaultAuthRuleName)

var tweetServiceBusQueueAuthRuleName = '${tweetServiceBusQueueName}-listen-rule'
var tweetServiceBusQueueAuthRuleId = resourceId('Microsoft.ServiceBus/namespaces/queues/authorizationRules', serviceBusNamespaceName, tweetServiceBusQueueName, tweetServiceBusQueueAuthRuleName)

var ocrServiceBusTopicListenAuthRuleName = '${OcrServiceBusTopicName}-listen-rule'
var ocrServiceBusTopicListenAuthRuleId = resourceId('Microsoft.ServiceBus/namespaces/topics/authorizationRules', serviceBusNamespaceName, OcrServiceBusTopicName, ocrServiceBusTopicListenAuthRuleName)

var ocrServiceBusTopicSendAndListenAuthRuleName = '${OcrServiceBusTopicName}-sendandlisten-rule'
var ocrServiceBusTopicSendAndListenAuthRuleId = resourceId('Microsoft.ServiceBus/namespaces/topics/authorizationRules', serviceBusNamespaceName, OcrServiceBusTopicName, ocrServiceBusTopicSendAndListenAuthRuleName)

var nexthopServiceBusTopicListenAuthRuleName = '${nextHopServiceBusTopicName}-listen-rule'
var nexthopServiceBusTopicListenAuthRuleId = resourceId('Microsoft.ServiceBus/namespaces/topics/authorizationRules', serviceBusNamespaceName, nextHopServiceBusTopicName, nexthopServiceBusTopicListenAuthRuleName)

var nexthopServiceBusTopicSendAndListenAuthRuleName = '${nextHopServiceBusTopicName}-sendandlisten-rule'
var nexthopServiceBusTopicSendAndListenAuthRuleId = resourceId('Microsoft.ServiceBus/namespaces/topics/authorizationRules', serviceBusNamespaceName, nextHopServiceBusTopicName, nexthopServiceBusTopicSendAndListenAuthRuleName)

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: sbSku
  }
  properties: {}

  resource serviceBusNamespaceAuthRule 'AuthorizationRules@2021-01-01-preview' = {

    name: defaultAuthRuleName
    properties: {
      rights: authRulesDefault
    }
  } 
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-01-01-preview' = {
  parent: serviceBusNamespace
  name: tweetServiceBusQueueName
  properties: {
    lockDuration: 'PT2M'
    defaultMessageTimeToLive: 'PT5M'  
    maxSizeInMegabytes: 2048
    requiresDuplicateDetection: true
    requiresSession: false      
    deadLetteringOnMessageExpiration: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 5
    enablePartitioning: true
  }
  resource serviceBusQueueListenRule 'authorizationRules@2021-01-01-preview' = {
    name: tweetServiceBusQueueAuthRuleName
    properties: {
      rights: authRulesListen
    }
  }
  resource serviceBusQueueSendAndListenRule 'authorizationRules@2021-01-01-preview' = {
    name: '${tweetServiceBusQueueName}-sendandlisten-rule'
    properties: {
      rights: authRulesSendAndListen
    }
  }
}

resource serviceBusOcrTopic 'Microsoft.ServiceBus/namespaces/topics@2021-01-01-preview' = {
  parent: serviceBusNamespace
  name: OcrServiceBusTopicName
  properties: {
    defaultMessageTimeToLive: 'PT2M'
    maxSizeInMegabytes: 2048      
    requiresDuplicateDetection: true
    enableBatchedOperations: true
    supportOrdering: true
    enablePartitioning: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
  }
  resource serviceBusTopicListenRule 'authorizationRules@2021-01-01-preview' = {
    name: ocrServiceBusTopicListenAuthRuleName
    properties: {
      rights: authRulesListen
    }
  }
  resource serviceBusTopicSendAndListenRule 'authorizationRules@2021-01-01-preview' = {
    name: ocrServiceBusTopicSendAndListenAuthRuleName
    properties: {
      rights: authRulesSendAndListen
    }
  }
}

resource serviceBusNextHopTopic 'Microsoft.ServiceBus/namespaces/topics@2021-01-01-preview' = {
  parent: serviceBusNamespace
  name: nextHopServiceBusTopicName
  properties: {
    defaultMessageTimeToLive: 'PT2M'
    maxSizeInMegabytes: 2048      
    requiresDuplicateDetection: true
    enableBatchedOperations: true
    supportOrdering: true
    enablePartitioning: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
  }
  resource serviceBusTopicListenRule 'authorizationRules@2021-01-01-preview' = {
    name: nexthopServiceBusTopicListenAuthRuleName
    properties: {
      rights: authRulesListen
    }
  }
  resource serviceBusTopicSendAndListenRule 'authorizationRules@2021-01-01-preview' = {
    name: nexthopServiceBusTopicSendAndListenAuthRuleName
    properties: {
      rights: authRulesSendAndListen
    }
  }
}

resource serviceBusOcrSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-01-01-preview' = {

  parent: serviceBusOcrTopic
  name: ocrServiceBusSubscriptionName
  properties: {
    lockDuration: 'PT1M'
    defaultMessageTimeToLive: 'PT2M'
    deadLetteringOnFilterEvaluationExceptions: false
    deadLetteringOnMessageExpiration: false  
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 5  
    enableBatchedOperations: true
    requiresSession: true

  }
}

resource serviceBusNextHopSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-01-01-preview' = {

  parent: serviceBusNextHopTopic
  name: nextHopServiceBusSubscriptionName
  properties: {
    lockDuration: 'PT1M'
    defaultMessageTimeToLive: 'PT5M'
    deadLetteringOnFilterEvaluationExceptions: false
    deadLetteringOnMessageExpiration: true  
    duplicateDetectionHistoryTimeWindow: 'PT2M'
    maxDeliveryCount: 5  
    enableBatchedOperations: true
    requiresSession: true

  }  
}

output sbId string = serviceBusNamespace.id

output serviceBusNamespacePrimaryConnectionString string = listkeys(serviceBusNamespaceAuthRuleId, '2021-01-01-preview').primaryConnectionString
output serviceBusNamespacePrimaryKey string = listkeys(serviceBusNamespaceAuthRuleId, '2021-01-01-preview').primarykey

output tweetServiceBusQueuePrimaryConnectionString string = listkeys(tweetServiceBusQueueAuthRuleId, '2021-01-01-preview').primaryConnectionString
output tweetServiceBusQueuePrimaryKey string = listkeys(tweetServiceBusQueueAuthRuleId, '2021-01-01-preview').primarykey

output ocrServiceBusTopicListenPrimaryConnectionString string = listkeys(ocrServiceBusTopicListenAuthRuleId, '2021-01-01-preview').primaryConnectionString
output ocrServiceBusTopicListenPrimaryKey string = listkeys(ocrServiceBusTopicListenAuthRuleId, '2021-01-01-preview').primarykey

output ocrServiceBusTopicSendAndListenPrimaryConnectionString string = listkeys(ocrServiceBusTopicSendAndListenAuthRuleId, '2021-01-01-preview').primaryConnectionString
output ocrServiceBusTopicSendAndListenPrimaryKey string = listkeys(ocrServiceBusTopicSendAndListenAuthRuleId, '2021-01-01-preview').primarykey

output nexthopServiceBusTopicListenPrimaryConnectionString string = listkeys(nexthopServiceBusTopicListenAuthRuleId, '2021-01-01-preview').primaryConnectionString
output nexthopServiceBusTopicListenPrimaryKey string = listkeys(nexthopServiceBusTopicListenAuthRuleId, '2021-01-01-preview').primarykey

output nexthopServiceBusTopicSendAndListenPrimaryConnectionString string = listkeys(nexthopServiceBusTopicSendAndListenAuthRuleId, '2021-01-01-preview').primaryConnectionString
output nexthopServiceBusTopicSendAndListenPrimaryKey string = listkeys(nexthopServiceBusTopicSendAndListenAuthRuleId, '2021-01-01-preview').primarykey
