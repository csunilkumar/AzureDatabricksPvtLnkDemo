@description('Network Location.')
param vnetLocation string = resourceGroup().location

@description('The name of the virtual network to create.')
param spoke1VnetName string

@description('Cidr range for the spoke vnet.')
param spoke1VnetCidr string 

@description('Cidr range for the private subnet.')
param privateSubnetName string = 'ADB_Private_subnet'
param privateSubnetCidr string 

@description('Cidr range for the public subnet.')
param publicSubnetName string = 'ADB_Public_subnet'
param publicSubnetCidr string


@description('Cidr range for the public subnet.')
param privateLinkSubnetName string = 'ADB_Pvt_Lnk_Subnet'
param privateLinkSubnetCidr string 

@description('The name of the existing network security group to create.')
param securityGroupName string


var securityGroupId = resourceId('Microsoft.Network/networkSecurityGroups', securityGroupName)

resource spoke1Vnet_resource 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: spoke1VnetName
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        spoke1VnetCidr
      ]
    }
    subnets: [
      {
        name: privateSubnetName
        properties: {
          addressPrefix: privateSubnetCidr
          networkSecurityGroup:{
            id:securityGroupId
          }
        delegations: [
            {
              name: 'databricks-del-private'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
        }
      }
      {
        name: publicSubnetName
        properties: {
          addressPrefix: publicSubnetCidr
          networkSecurityGroup:{
            id:securityGroupId
          }
          delegations: [
            {
              name: 'databricks-del-public'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
        }
      }
      {
        name: privateLinkSubnetName
        properties: {
          addressPrefix: privateLinkSubnetCidr
          networkSecurityGroup:{
            id:securityGroupId
          }
        }
      }      
    ]
  }
}

// output spoke_vnet_id string = spokeVnetName_resource.id
output ADB_Privatesubnet_id string = resourceId('Microsoft.Network/virtualNetworks/subnets', spoke1VnetName, privateSubnetName)
output ADB_publicsubnet_id string = resourceId('Microsoft.Network/virtualNetworks/subnets', spoke1VnetName, publicSubnetName)
output privatelinksubnet_id string = resourceId('Microsoft.Network/virtualNetworks/subnets', spoke1VnetName, privateLinkSubnetName)
output spoke1VnetId string = spoke1Vnet_resource.id
