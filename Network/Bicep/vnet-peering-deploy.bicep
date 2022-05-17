param vnetName string
param remoteVnetName string
param remoteVnetRG string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource vnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  parent: vnet
  name: '${vnetName}-${remoteVnetName}-peering'
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork:{
      id: resourceId(remoteVnetRG, 'Microsoft.Network/virtualNetworks', remoteVnetName)
    }
  }  
}
