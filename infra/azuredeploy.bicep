@description('Name of the application')
param appName string = 'ebon-app'

@description('Primary region of the resources')
param primaryRegion string = 'australiasoutheast'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Secondary regions of the resources')
param secondaryRegions array = [
  'westeurope'
  'westus'
]

@description('Combine primary region with secondary ones using concat function.')
var locations = concat([primaryRegion], secondaryRegions)

@description('Combine primary region with secondary ones using for-loop.')
var cosmosLocations = [
  for i in range(0, length(locations)): {
    locationName: locations[i]
    failoverPriority: i
    isZoneRedundant: false
  }
]

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview' = {
  name: '${appName}-cosmos'
  location: primaryRegion
  tags: {
    defaultExperience: 'Core (SQL)'
    'hidden-cosmos-mmspecial': ''
  }
  properties: {
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: 'Enabled'
    enableFreeTier: true
    enableMultipleWriteLocations: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: cosmosLocations
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = [for i in range(0, length(locations)): {
  name: substring(replace('${locations[i]}sa${appName}', '-', ''), 0, min(24, length(appName)))
  location: locations[i]
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}]

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = [for i in range(0, length(locations)): {
  name: '${appName}-hosting-${locations[i]}'
  location: locations[i]
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}]

resource functionApp 'Microsoft.Web/sites@2021-03-01' = [for i in range(0, length(locations)): {
  name: '${appName}-func-${locations[i]}'
  location: locations[i]
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan[i].id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${substring(replace('${locations[i]}sa${appName}', '-', ''), 0, min(24, length(appName)))};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount[i].listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${substring(replace('${locations[i]}sa${appName}', '-', ''), 0, min(24, length(appName)))};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount[i].listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('${appName}-func-${locations[i]}')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'Location'
          value: locations[i]
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}]

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-ai'
  location: primaryRegion
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
