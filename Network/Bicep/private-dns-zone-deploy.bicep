param zoneName string
param aRecordName string
param aRecordsArray array = []
param cnameRecord string = ''
param cnameAlias string = ''
param vnetName string = ''
param vnetResourceGroup string = ''
param ttl int
param location string = 'global'

resource pvtDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: location
  properties: {}
}

resource aRecords 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: pvtDNSZone
  name: aRecordName
  properties: {    
    aRecords: [for aRecord in aRecordsArray: {      
      ipv4Address: aRecord
    }]
    ttl: ttl
  }  
}

resource cnameRecords 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  parent: pvtDNSZone
  name: cnameRecord  
  properties: {    
    cnameRecord: {
      cname: cnameAlias
    }    
    ttl: ttl    
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: pvtDNSZone
  name: '${vnetName}-${zoneName}-plink'
  location: location
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}
