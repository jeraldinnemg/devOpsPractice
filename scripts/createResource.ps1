#------------------------------------------------------- 
#-------- Parameters for the script  --------- 
#------------------------------------------------------- 
param(
    [ValidateSet("create", "delete")]
    [Parameter(Mandatory)][string]$Action,
    [Parameter(Mandatory)][string]$ResourceName,
    [switch]$ResourceGroup,
    [switch]$AppServicePlan,
    [switch]$AppService,
    [switch]$AppInsights,
    [switch]$All,
    [string]$ResourceGroupName,
    [string]$AppServicePlanName,
    [string]$AppServiceName,
    [string]$AppInsightsName
  )

#------------------------------------------------------- 
#-----------Function to create all resoruces ----------
#-------------------------------------------------------


function CreateAllResources {
  param(
  $locationPrimary = "East US",
  $locationSecondary = "West US"
  )


  $resourceGName = "USEDCTPJMRSG01"
  
  $existingRG = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $resourceGName }
  if(!$existingRG){
  New-AzResourceGroup -Name $resourceGName -Location $locationPrimary
  }


  #Call the function to validate if the resource alredy exists           
  # while (ValidateResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName) {
  #   Write-LogCustom -Message "The name $ResourceGroupName is not available in Azure"
  #   $ResourceGroupName = CreateResourceName -ResourceType "Resource group"
  # }
  # Write-LogCustom -Message "New resource group $ResourceGroupName created successfully"
            
  #Deploy the RSG in Azure

            
  # if (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $ResourceGroupName) {
  #   Write-LogCustom -Message "Resource Group $ResourceGroupName created successfully"
  # }
  # else {
  #   Write-LogCustom -Message "Failed to create Resource Group $ResourceGroupName"
  # }

  #Call the function to create de ASP Name
  #$AppServicePlanName = $ResourceName
            
  #Call the function to validate if the resource alredy exists
  # while (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppServicePlanName) {
  #   Write-LogCustom -Message "The name $AppServicePlanName is not available in Azure"
  #   $AppServicePlanName = CreateResourceName 
  # }
  # Write-LogCustom -Message "New app service plan $AppServicePlanName created successfully"
          
  #Deploy the ASP in Azure
  elseif($ResourceType -eq "App Service Plan"){
  New-AzAppServicePlan  `
    -Name $AppServicePlanName `
    -ResourceGroupName $resourceGName  `
    -Location $locationSecondary `
    -Tier "F1"
  }
    #Validate the name
  # if (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppServicePlanName) {
  #   Write-LogCustom -Message "App Service Plan $AppServicePlanName created successfully"
  # }
  # else {
  #   Write-LogCustom -Message "Failed to create App Service Plan $AppServicePlanName"
  # }
 
  #Call the function to create de App Service
  #$AppServiceName = $ResourceName
            
  #Call the function to validate if the resource alredy exists
  # while (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppServiceName) {
  #   Write-LogCustom -Message "The name $AppServiceName is not available in Azure"
  #   $AppServiceName = CreateResourceName 
  # }
  # Write-LogCustom -Message "New app service name $AppServiceName created successfully"
          
  #Deploy the App service in Azure
  elseif($ResourceType -eq "App Service"){
  New-AzWebApp  `
    -Name $AppServiceName `
    -ResourceGroupName $resourceGName  `
    -AppServicePlan $appServicePlanName   `
    -Location $locationSecondary `
  }

  Write-Host "##vso[task.setvariable variable=AppService]$AppService"
  # #Validate the name
  # if (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppServiceName) {
  #   Write-LogCustom -Message "App Service $AppServiceName created successfully"
  # }
  # else {
  #   Write-LogCustom -Message "Failed to create App Service $AppServiceName"
  # }

 #Call the function to create de Application Insights instance name
#  $AppInsightsName = $ResourceName
            
 #Call the function to validate if the resource alredy exists
#  while (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppInsightsName) {
#    Write-LogCustom -Message "The name $AppInsightsName is not available in Azure"
#    $AppInsightsName = CreateResourceName 
#  }
#  Write-LogCustom -Message "New application insights $AppInsightsName created successfully"
         
 #Deploy the App insights in Azure
 elseif($ResourceType -eq "Application Insights"){
 New-AzApplicationInsights  `
   -Name $AppInsightsName `
   -ResourceGroupName $resourceGName  `
   -Location $locationPrimary `
 }

   # Get the App Service and Application Insights resources
   #$webApp = Get-AzWebApp -Name $AppServiceName -ResourceGroupName $ResourceGroupName
   #$AppInsights = Get-AzApplicationInsights -Name $AppInsightsName -ResourceGroupName $ResourceGroupName
   
   # Associate the Application Insights instance to the App Service
   #$AppInsightsId = (Get-AzResource -Name $AppInsightsName -ResourceGroupName $ResourceGroupName).ResourceId
   
   #Set-AzWebApp -WebApp $webApp -ApplicationInsightsId $AppInsightsId



 #Validate the name
#  if (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppInsightsName) {
#    Write-LogCustom -Message "Application Insights $AppInsightsName created successfully"
#  }
#  else {
#    Write-LogCustom -Message "Failed to create App Service Plan $AppInsightsName"
#  }

}

function CreateResourceGroup {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    $location = "eastus"
  )
  if (!(ValidateResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $location
  }
}

function CreateAppServicePlan {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$AppServicePlanName,
    $location = "East US"
  )
  # crear asp
  New-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -Location $location -Tier "F1"
  #validar que se haya creado
  if (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppServicePlanName) {
    Write-LogCustom -Message "App Service Plan $AppServicePlanName created successfully"
  }
  else {
    Write-LogCustom -Message "Failed to create App Service Plan $AppServicePlanName"
  }
}

function CreateAppService {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$AppServicePlanName,
    [Parameter(Mandatory)][string]$AppServiceName,
    $location = "West US"
  )
  # create app service WAP

  New-AzWebApp  `
    -Name $AppServiceName `
    -ResourceGroupName $ResourceGroupName `
    -AppServicePlan $AppServicePlanName   `
    -Location $location `

  #Validate if resource exist
  if (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppServiceName) {
    Write-LogCustom -Message "App Service $AppServiceName created successfully"
  }
  else {
    Write-LogCustom -Message "Failed to create App Service Plan $AppServiceName"
  }
}

function CreateAppInsights {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$AppInsightsName,
    $location = "East US"
  )
  # crear app insights

  New-AzApplicationInsights  `
  -Name $AppInsightsName `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `


  #validar que se haya creado
  if (ValidateResourceExists -RsgOrRsc "rsc" -ResourceName $AppInsightsName) {
    Write-LogCustom -Message "AppInsight $AppInsightsName created successfully"
  }
  else {
    Write-LogCustom -Message "Failed to create AppInsight $AppInsightsName"
  }
}

function DeleteResource {
  # Delete all the resources
  param(
    [Parameter(Mandatory = $null)][string]$ResourceGroupName,
    [Parameter(Mandatory = $null)][string]$AppServicePlanName,
    [Parameter(Mandatory = $null)][string]$AppServiceName

  )
  if ($ResourceGroupName) {
    $existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
    if ($null -eq $existingResourceGroup) {
      Write-LogCustom -Message "There is no Resource Group named $ResourceGroupName"
    }
    else {
      Write-LogCustom -Message "Starting deleted of Resource Group named $ResourceGroupName.."
      $r = Remove-AzResourceGroup -Name $ResourceGroupName -Force
      Start-sleep -Seconds 10
      $existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
      if (!$existingResourceGroup) {
        Write-LogCustom -Message "The Resource Group $ResourceGroupName was deleted successfully "
      }
    }
  }
  if ($AppServicePlanName) {
    $allresource = Get-AzResource | Where-Object { $_.Name -eq $AppServicePlanName } | Select-Object ResourceGroupName
    if ($null -eq $allresource) {
      Write-LogCustom -Message "There is no App Service Plan named $AppServicePlanName"
    }
    else {
      $listresource = @()
      foreach ($resource in $allresource) {
        $listresource += $resource.ResourceGroupName
      }
      if ($listresource.Count -ge 2) {
        Write-LogCustom -Message "There are more than one resource with the name $AppServicePlanName. Please, write the ResourceGroupName to continue with the deleted."
        $RGN = Read-Host("Resourse Group Name")
        Remove-AzResource `
          -ResourceGroupName $RGN `
          -ResourceName $AppServicePlanName `
          -ResourceType Microsoft.Web/serverfarms `
          -Force
      }
      else {
        Write-LogCustom -Message "Starting deleted of App Service Plan named $AppServicePlanName.."
        $r = Remove-AzResource `
          -ResourceGroupName $listresource[0] `
          -ResourceName $AppServicePlanName `
          -ResourceType Microsoft.Web/serverfarms `
          -Force
        Start-sleep -Seconds 10
        # $existingResource = Get-AzResource | Where-Object { $_.Name -eq $AppServicePlanName }
        if ($r -eq $true) {
          Write-LogCustom -Message "The App Service Plan $AppServicePlanName was deleted successfully"
        }
        else {
          Write-LogCustom -Message "Failed to delete App Service Plan named $AppServicePlanName"
        }
      }
    }
  }

}


#------------------------------------------------------- 
#----------- Deploying resources to azure --------------
#-------------------------------------------------------


# Connect to azure and authenticate with suscription ID

Connect-AzAccount

if ($Action -eq "create") {
  # Create all. The user introduce "All" as parameter
  CreateAllResources
}
  

#------------------------------------------------------- 
#----------- Delete resources in azure--- --------------
#-------------------------------------------------------