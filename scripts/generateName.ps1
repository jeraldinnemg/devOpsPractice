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
      $global:ResourceName = $ResourceName
      Write-Host "##vso[task.setvariable variable=ResourceName;]$ResourceName"
      return $ResourceName 
      Write-LogCustom -Message $ResourceName
    }

    catch {
      Write-LogCustom -Message  "Failed to create"
    }
  }


