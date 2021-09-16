param(
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$RulesFile,
    [Parameter(Mandatory=$true)]$SubscriptionId
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force -AllowClobber
Import-Module AzSentinel

#Name of the Azure DevOps artifact
$artifactName = "_Sentinel Rule Pipeline\SentinelFiles\HuntingRules"

#Build the full path for the hunting rules file
$artifactPath = Join-Path $env:System_DefaultWorkingDirectory $artifactName 
$rulesFilePath = Join-Path $artifactPath $RulesFile

#Getting all hunting rules from file
$rules = Get-Content -Raw -Path $rulesFilePath | ConvertFrom-Json

foreach ($rule in $rules.hunting) {
    Write-Host "Processing hunting rule: " -NoNewline 
    Write-Host "$($rule.displayName)" -ForegroundColor Green

    $existingRule = Get-AzSentinelHuntingRule -WorkspaceName $Workspace -RuleName $rule.displayName -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Hunting rule $($rule.displayName) already exists. Updating..."

        New-AzSentinelHuntingRule -SubscriptionId $SubscriptionId -WorkspaceName $Workspace -DisplayName $rule.displayName -Query $rule.query -Description $rule.description -Tactics $rule.tactics -confirm:$false
    }
    else {
        Write-Host "Hunting rule $($rule.displayName) doesn't exist. Creating..."

        New-AzSentinelHuntingRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Query $rule.query -Description $rule.description -Tactics $rule.tactics -confirm:$false
    }
}