#------------------------------------------------------- 
#-------- Function to save logs of the script  --------- 
#------------------------------------------------------- 
 function Write-LogCustom {
    param (
      [Parameter(Mandatory)][string]$Message
    )
    $logPath = ".\log"
    $logName = "run"
    $logFile = "$logPath\$logName.log"

    # If the folder not exists create a new one
    if (!(Test-Path -Path $logPath)) {

      New-Item $logPath -Type Directory | Out-Null
    }
    try {
      $dateTime = Get-Date -Format 'MM-dd-yy HH:mm:ss'
      $logToWrite = $dateTime + ": " + $Message
    
    # Add-Content creates the file so there's no need to check if the file already exists
      Add-Content -Path $logFile -Value $logToWrite
    }
    catch {
      $dateTime = Get-Date -Format 'MM-dd-yy HH:mm:ss'
      $logToWrite = $dateTime + ": Failed to give a message"
      Add-Content -Path $logFile -Value $logToWrite
    }
  }

#------------------------------------------------------- 
#-----Function to create the name of the resource ------
#-------------------------------------------------------
  function CreateResourceName {

    param(
      [Parameter(Mandatory)]
      [string]$Location,
      [ValidateSet("DEV", "QA", "UAT", "PROD")]
      [string]$Environment = "DEV",
      [ValidateSet("CTP")]
      [string]$ProjectName = "CTP",
      [ValidateSet("Jeraldinne Molleda")]
      [string]$CandidateName = "Jeraldinne Molleda",
      [Parameter(Mandatory)]
      [string]$ResourceType
    )

    try {
      $LocationHash = @{
        "East US" = "USE"
        "East US 2" = "UE2"
        "West US" = "UWU"
        "West US 2" = "UW2"    
      }
      $LocationCode = $LocationHash.$Location

      $EnvironmentHash = @{
        "DEV" = "D"
        "QA" = "Q"
        "UAT" = "U"
        "PROD" = "P"
      }

      $EnvironmentCode = $EnvironmentHash.$Environment

      $ResourceTypeHash = @{
        "Resource Group" = "RSG"
        "App Service" = "WAP"
        "App Service Plan" = "ASP"
        "Application Insights" = "AIS"
        "Automation Account" = "AAA"
      }

      $ResourceTypeCode = $ResourceTypeHash.$ResourceType

      # Get the first letter of the first name and the first letter of the last name
        
      $CandidateNameInitials = $CandidateName[0] + $CandidateName.split()[1][0]

      $numbers = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

      $InstanceNumber =  $numbers | Get-Random -Count 2

      
      while($instanceNumber -eq "00"){
        $InstanceNumber = $numbers | Get-Random -Count 2
      }

      $ResourceName = ($LocationCode + $EnvironmentCode + $ProjectName + $CandidateNameInitials + $ResourceTypeCode + $InstanceNumber).Replace(" ", "").ToUpper()

      return $ResourceName 
      Write-Host "##vso[task.setvariable variable=resourceName]$ResourceName"
      Write-LogCustom -Message $ResourceName
    }

    catch {
      Write-LogCustom -Message  "Failed to create"
    }
  }

#------------------------------------------------------- 
#-----Function to validate the resource name -----------
#-------------------------------------------------------
function ValidateResourceName {
  # Check if the resource name is according to the 'Naming Convention'
  # Example:
  # The name of an App Service deployed in West US would be: UWUDCTPPCWAP01
  # UWU => West US
  # D => Development
  # CTP => Project Name
  # PC => Candidate Name
  # WAP => Web Application
  # 01 => Instance Number
  
  param(
    [Parameter(Mandatory)]$ResourceName
  )
  $ValidationStatus = $true
  $LengthExpected = 14
  $OnlyAlphanumericRegex = '^[a-zA-Z0-9]+$'

  $LocationHash = @{
    "USE" = "East US"
    "UE2" = "East US 2"
    "UWU" = "West US"
    "UW2" = "West US 2"
  }
  $EnvironmentHash = @{
    "D" = "DEV"
    "Q" = "QA"
    "U" = "UAT"
    "P" = "PROD"
  }
  $ResourceTypeHash = @{
    "RSG" = "Resource Group" 
    "WAP" = "App Service"
    "ASP" = "App Service Plan"
    "AIS" = "Application Insights"
    "AAA" = "Automation Account"
  }

  $Location = $ResourceName.Substring(0,3)
  $Environment = $ResourceName.Substring(3,1)
  $ResourceType = $ResourceName.Substring(9,3)
  if($LocationHash.ContainsKey($Location)) {
    Write-LogCustom -Message "Location $($LocationHash.$Location) is valid"
  }
  else { 
    Write-LogCustom -Message "Location $Location is Not supported"
    $ValidationStatus = $false
  }
  if($EnvironmentHash.ContainsKey($Environment)) {
    Write-LogCustom -Message "Environment $($EnvironmentHash.$Environment) is valid"
  }
  else {
    Write-LogCustom -Message "Environment $Environment is Not supported"
    $ValidationStatus = $false
  }
  if($ResourceTypeHash.ContainsKey($ResourceType)) {
    Write-LogCustom -Message "Resource Type $($ResourceTypeHash.$ResourceType) is valid" 
  }
  else {
    Write-LogCustom -Message "Resource Type $ResourceType is Not supported"
    $ValidationStatus = $false
  }
  if($ResourceName -match $OnlyAlphanumericRegex){
    Write-LogCustom -Message "Resource Name chars are valid"
    $ValidationStatus = $false

    if ($ResourceName.Length -eq $LengthExpected){
      Write-LogCustom -Message  "The name length is $($ResourceName.Length) is valid"
    }
    else{
      Write-LogCustom -Message  "The name length is $($ResourceName.Length) while it's expected $LengthExpected"
      $ValidationStatus = $false
    }
  }
  else{
    Write-LogCustom -Message "Only alphanumeric characters are accepted"
    $ValidationStatus = $false
  }
  return $ValidationStatus
}

  
#------------------------------------------------------- 
#-Funtion to validate if the resource exists in Az------
#-------------------------------------------------------
function ValidateResourceExists {
    
  param(
    [ValidateSet("rsg", "rsc")]
    [Parameter(Mandatory)][string]$RsgOrRsc,
    [Parameter(Mandatory)][string]$ResourceName
  )
  try{
    $ValidationStatus = $true
    if($RsgOrRsc -eq "rsg"){
      $existingRsg = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceName }
      if(!$existingRsg){
        $ValidationStatus = $false
      }
    }
    elseif($RsgOrRsc -eq "rsc"){
      $existingRsc = Get-AzResource | Where-Object { $_.Name -eq $ResourceName }
      if(!$existingRsc){
        $ValidationStatus = $false
      }
    }
    return $ValidationStatus
    Write-LogCustom -Message "The name is available"
  }
  catch{
    Write-LogCustom -Message "Failed to validate if the resource exists in Azure"
  }
}


