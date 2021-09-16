param(
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$RulesFile,
    [Parameter(Mandatory=$true)]$SubscriptionId
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force -AllowClobber
Import-Module AzSentinel

#Name of the Azure DevOps artifact
$artifactName = "_Sentinel Rule Pipeline\SentinelFiles\AnalyticsRules"

#Build the full path for the analytics rule file
$artifactPath = Join-Path $env:System_DefaultWorkingDirectory $artifactName
$rulesFilePath = Join-Path $artifactPath $RulesFile

try {
    Import-AzSentinelAlertRule -SubscriptionId $SubscriptionId -WorkspaceName $Workspace -SettingsFile $rulesFilePath
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Error "Rule import failed with message: $ErrorMessage" 
}