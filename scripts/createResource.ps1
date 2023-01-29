param(
    [Parameter(Mandatory)]$resourceName
)


$resourceGName = "USEDCTPMCRSG01"
$existingRG = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $resourceGName }

if(!$existingRG){
    New-AzResourceGroup -Name $resourceGName -Location "East US"
}

if($resourceName -like "*WAP*"){
    New-AzWebApp -ResourceGroupName $resourceGName -Name $resourceName -Location "West US"
    Write-Host "##vso[task.setvariable variable=webAppName]$resourceName"
    Write-Host "hola"

}
elseif($resourceName -like "*ASP*") {
    New-AzAppServicePlan -ResourceGroupName $resourceGName -Name $resourceName -Location "West US" -Tier "Free"
}
elseif($resourceName -like "*AIS*") {
    New-AzApplicationInsights -ResourceGroupName $resourceGName -Name $resourceName -Location "East US" 
    
}
   # Get the App Service and Application Insights resources
   #$webApp = Get-AzWebApp -Name $AppServiceName -ResourceGroupName $ResourceGroupName
   #$AppInsights = Get-AzApplicationInsights -Name $AppInsightsName -ResourceGroupName $ResourceGroupName
   
   # Associate the Application Insights instance to the App Service
   #$AppInsightsId = (Get-AzResource -Name $AppInsightsName -ResourceGroupName $ResourceGroupName).ResourceId
   
   #Set-AzWebApp -WebApp $webApp -ApplicationInsightsId $AppInsightsId
