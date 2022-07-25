@description('')
param pvtEndPointLocation string = resourceGroup().location

param privateEndpoints_workspaceEndpoint_name string = 'workspaceEndpoint'
param workSpaceID string
param privateLinkSubnetId string 


//var workSpaceResourceID = resourceId('Microsoft.Databricks/workspaces', workSpaceID)
//var privateLinkSubnetResourceID =  privateLinkSubnetId //resourceId('Microsoft.Network/virtualNetworks/subnets', privateLinkSubnetId)

resource privateEndpoints_workspaceEndpoint_name_resource 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: privateEndpoints_workspaceEndpoint_name
  location: pvtEndPointLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpoints_workspaceEndpoint_name
        properties: {
          privateLinkServiceId: workSpaceID
          
          //'/subscriptions/5726c027-4022-49e6-87bf-01cb66e8fd6b/resourceGroups/${resourceGroup()}/providers/Microsoft.Databricks/workspaces/${workSpaceID}'
          groupIds: [
            'databricks_ui_api'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: privateLinkSubnetId
    }
    // customDnsConfigs: [
    //   {
    //     fqdn: 'adb-8981839825346669.9.azuredatabricks.net'
    //     ipAddresses: [
    //       '10.2.3.4'
    //     ]
    //   }
    // ]
  }
}

