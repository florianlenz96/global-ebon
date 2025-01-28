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

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string

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
    enableFreeTier: false
    enableMultipleWriteLocations: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: cosmosLocations
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = [for i in range(0, length(locations)): {
  name: substring(replace('${locations[i]}sa${appName}', '-', ''), 0, min(24, length(replace('${locations[i]}sa${appName}', '-', ''))))
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
  dependsOn: [
    hostingPlan[i]
    storageAccount[i]
    cosmosDbAccount
    applicationInsights
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan[i].id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${substring(replace('${locations[i]}sa${appName}', '-', ''), 0, min(24, length(replace('${locations[i]}sa${appName}', '-', ''))))};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount[i].listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${substring(replace('${locations[i]}sa${appName}', '-', ''), 0, min(24, length(replace('${locations[i]}sa${appName}', '-', ''))))};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount[i].listKeys().keys[0].value}'
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
        {
          name: 'CosmosDBConnection'
          value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
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

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: '${appName}-fd'
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: '${appName}-fd-backend'
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 0
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for i in range(0, length(locations)): {
  name: '${appName}-fd-origin-${locations[i]}'
  parent: frontDoorOriginGroup
  properties: {
    hostName: functionApp[i].properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: functionApp[i].properties.defaultHostName
    priority: 1
    weight: 1000
  }
}]

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'default'
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}
