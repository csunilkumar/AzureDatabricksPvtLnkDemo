//Workspace  configuration
@description('')
param adbWorkspaceLocation string = resourceGroup().location

@allowed([
  'standard'
  'premium'
])
@description('The pricing tier of workspace.')
param pricingTier string = 'premium'

@description('Indicates whether to have NPIP workspace - boolean with true or false')
param enableNoPublicIp bool = true

@description('Indicates whether public network access is allowed to the workspace with private endpoint - possible values are Enabled or Disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Indicates whether to retain or remove the AzureDatabricks outbound NSG rule - possible values are AllRules or NoAzureDatabricksRules')
@allowed([
  'AllRules'
  'NoAzureDatabricksRules'
])
param requiredNsgRules string = 'NoAzureDatabricksRules'

@description('')
param adbWorkspaceName string = 'databricks${uniqueString(resourceGroup().id)}'
var managedResourceGroupName = 'databricks-rg-${adbWorkspaceName}-${uniqueString(adbWorkspaceName, resourceGroup().id)}'
var managedResourceGroupId = '${subscription().id}/resourceGroups/${managedResourceGroupName}'

//Workspace - Network configuration
@description('')
var vnetId = resourceId('Microsoft.Network/virtualNetworks', vnetName)

param vnetName string = 'ADB_PRVT_VNET'

@description('Name for the Private Subnet used for containers')
param publicSubnetName string = 'ADB_Public_subnet'
@description('Name for the Public Subnet used for VM to communicate')
param privateSubnetName string = 'ADB_Private_subnet'


resource adbWorkspace_privatelink_resource 'Microsoft.Databricks/workspaces@2021-04-01-preview' = {
  name: adbWorkspaceName
  location: adbWorkspaceLocation
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      customPrivateSubnetName: {
        value: privateSubnetName
      }
      customPublicSubnetName: {
        value: publicSubnetName
      }
      customVirtualNetworkId: {
        value: vnetId
      }
      enableNoPublicIp: {
        value: enableNoPublicIp
      }
    }
    publicNetworkAccess: publicNetworkAccess
    requiredNsgRules: requiredNsgRules
  }
}



// resource workspaces_privatelink_endpoint 'Microsoft.Databricks/workspaces/privateEndpointConnections@2021-04-01-preview' = {
//   name: '${adbWorkspaceName}_EndpointConnections_566'
//   parent: adbWorkspace_privatelink_resource
//   properties: {
//     privateEndpoint: {}
//     privateLinkServiceConnectionState: {
//       status: 'Approved'
//     }
//   }  
// }

output databricks_workspace_id string= adbWorkspace_privatelink_resource.properties.workspaceId
output databricks_workspaceUrl string = adbWorkspace_privatelink_resource.properties.workspaceUrl
output databricks_workspaceid string = adbWorkspace_privatelink_resource.id

output databricks_dbfs_storage_accountName string = adbWorkspace_privatelink_resource.properties.parameters.storageAccountName.value
