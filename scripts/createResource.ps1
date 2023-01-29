#------------------------------------------------------- 
#-------- Parameters for the script  --------- 
#------------------------------------------------------- 
param(
    [Parameter(Mandatory)]$resourceName,
    $locationPrimary = "East US",
    $locationSecondary = "West US",
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



  $resourceGName = "USEDCTPJMRSG01"
  
  $existingRG = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $resourceGName }
  if(!$existingRG){
  New-AzResourceGroup -Name $resourceGName -Location $locationPrimary
  }

  #Deploy the ASP in Azure
if($resourceName -like "*ASP*"){
  New-AzAppServicePlan -Name $resourceName -ResourceGroupName $resourceGName -Location $locationSecondary -Tier "F1"
  }
          
  #Deploy the App service in Azure
elseif($resourceName -like "*WAP*"){
  New-AzWebApp -Name $resourceName -ResourceGroupName $resourceGName  -Location $locationSecondary `
    Write-Host "##vso[task.setvariable variable=appService]$resourceName"
  }
         
 #Deploy the App insights in Azure
 elseif($resourceName -like "*AIS*"){
 New-AzApplicationInsights  -Name $resourceName -ResourceGroupName $resourceGName  -Location $locationPrimary `
 }

   # Get the App Service and Application Insights resources
   #$webApp = Get-AzWebApp -Name $AppServiceName -ResourceGroupName $ResourceGroupName
   #$AppInsights = Get-AzApplicationInsights -Name $AppInsightsName -ResourceGroupName $ResourceGroupName
   
   # Associate the Application Insights instance to the App Service
   #$AppInsightsId = (Get-AzResource -Name $AppInsightsName -ResourceGroupName $ResourceGroupName).ResourceId
   
   #Set-AzWebApp -WebApp $webApp -ApplicationInsightsId $AppInsightsId
