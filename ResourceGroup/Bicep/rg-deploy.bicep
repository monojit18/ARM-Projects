param rgName string
param rgLocation string

resource symbolicname 'Microsoft.Resources/resourceGroups@2021-04-01' = {

  name: rgName
  location: rgLocation  
  properties: {}

}
