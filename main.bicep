targetScope = 'subscription'
@minLength(2)
@maxLength(4)
@description('2-4 chars ONLY to prefix the Azure Resources, DO NOT use number or symbol')
param prefix string = 'e3kc'
var uniqueSubString = '${uniqueString(guid(subscription().subscriptionId))}'
var uString = '${prefix}${uniqueSubString}'

var resourceGroupName = '${substring(uString, 0, 6)}-rg'

// inputs for  nsg.template.bicep
var nsgName = '${substring(uString, 0, 6)}-nsg'

@description('Default location of the resources')
param location string = 'westus2'

param VnetName string = 'ADB_PRVT_LNK_VNET'
param SpokeVnetCidr string = '10.201.0.0/16'
param PublicSubnetCidr string = '10.201.0.0/24'
param PrivateSubnetCidr string = '10.201.1.0/24' 
param PrivateLinkSubnetCidr string = '10.201.2.0/28'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  }

module nsg 'nsg.template.bicep' = {
  scope: rg
  name: nsgName
  params: {
    securityGroupName : nsgName
    nsgLocation:location
  }
  }

module vnets 'vnet.pvtlnk.template.bicep' = {
scope: rg
name: VnetName
params: {
  vnetLocation : location
 
  spoke1VnetName : VnetName
  spoke1VnetCidr: SpokeVnetCidr
  privateSubnetName: 'ADB_Private_subnet'
  privateSubnetCidr: PrivateSubnetCidr    
  publicSubnetName: 'ADB_Public_subnet'
  publicSubnetCidr: PublicSubnetCidr
  privateLinkSubnetCidr:PrivateLinkSubnetCidr
  privateLinkSubnetName: 'ADB_Pvt_Lnk_Subnet'

  securityGroupName: nsg.name
  
}
}

module workspace 'workspace.pvtlink.template.bicep'={
scope:rg
name: 'workSpacePvtLink'
params:{
  adbWorkspaceLocation:location
  enableNoPublicIp:true
  pricingTier:'premium'
  //privateSubnetName:vnets.outputs.ADB_Privatesubnet_id
  //publicSubnetName:vnets.outputs.ADB_publicsubnet_id
  publicNetworkAccess: 'Enabled'
  requiredNsgRules: 'NoAzureDatabricksRules'
  vnetName: vnets.name

}

}


module workspacePrivateEndPoint 'pvtendpoint.adb.template.bicep'={
  scope:rg
  name: 'worksparkPvtEndpoint'
  params:{
    privateLinkSubnetId:vnets.outputs.privatelinksubnet_id
    workSpaceID: workspace.outputs.databricks_workspaceid
    privateEndpoints_workspaceEndpoint_name: '${workspace.name}_EndpointConnections123'
    pvtEndPointLocation:location
  }
  dependsOn:[workspace]
}
