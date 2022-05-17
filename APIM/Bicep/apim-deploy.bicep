param apimName string
param location string = resourceGroup().location
param skuName string
param skuCapacity int
param vnetName string
param vnetPrefix string
param subnetName string
param subnetPrefix string
param vnetType string

var networkDeployName = '${apimName}-vnet-deploy'

// module networkModule '../../Network/Bicep/network-deploy.bicep' = {

//   name: networkDeployName
//   params: {

//     vnetName: vnetName
//     vnetPrefix: vnetPrefix
//     subnetName: subnetName
//     subnetPrefix: subnetPrefix
//     location: location
//   }
// }

resource apimDeploy 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apimName
  location: location
  sku: {
    capacity: skuCapacity
    name: skuName
  }
  properties: {
    publisherEmail: 'modatta@microsoft.com'
    publisherName: 'TestAPIM'
    disableGateway: false
    enableClientCertificate: true    
    virtualNetworkType: vnetType
  }
  
  // dependsOn: [
    
  //   networkModule

  // ]
}

output apimId string = apimDeploy.id
