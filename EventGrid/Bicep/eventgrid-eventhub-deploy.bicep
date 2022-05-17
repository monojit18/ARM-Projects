param eventGridTopicName string
param eventGridOCRSubscriptionName string
param eventGridEHOCRNamespace string
param eventGridEHOCRName string

@minValue(1)
@maxValue(7)
param messageRetentionInDays int = 1

@minValue(2)
@maxValue(32)
param partitionCount int = 4
param location string = resourceGroup().location

resource eventGridTopic 'Microsoft.EventGrid/topics@2020-06-01' = {

  name: eventGridTopicName
  location: location
}

resource destinationEventHubNamespace 'Microsoft.EventHub/namespaces@2018-01-01-preview' = {

  name: eventGridEHOCRNamespace
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 7
  }
}

resource destinationEventHub 'Microsoft.EventHub/namespaces/EventHubs@2017-04-01' = {

  parent: destinationEventHubNamespace
  name: eventGridEHOCRName
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
  }
}

resource eventGridSubscription 'Microsoft.EventGrid/eventSubscriptions@2020-06-01' = {

  scope: eventGridTopic
  name: eventGridOCRSubscriptionName
  properties: {
    destination: {
      endpointType: 'EventHub'
      properties: {
        resourceId: destinationEventHub.id
      }
    }
    filter: {
      isSubjectCaseSensitive: false
    }
  }
  dependsOn: [
    eventGridTopic
  ]
}

output endpoint string = eventGridTopic.properties.endpoint
