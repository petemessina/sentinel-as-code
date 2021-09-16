param(
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$ConnectorsFile,
    [Parameter(Mandatory=$true)]$TenantId,
    [Parameter(Mandatory=$true)]$SubscriptionId
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force -AllowClobber
Import-Module AzSentinel

#Name of the Azure DevOps artifact
$artifactName = "_Sentinel Rule Pipeline\SentinelFiles\Connectors"

#Build the full path for the analytics rule file
$artifactPath = Join-Path $env:System_DefaultWorkingDirectory $artifactName 
$rulesFilePath = Join-Path $artifactPath $ConnectorsFile

((Get-Content -path $rulesFilePath -Raw) -replace '__TENANTID__', $TenantId) | Set-Content -Path $rulesFilePath
((Get-Content -path $rulesFilePath -Raw) -replace '__SUBSCRIPTIONID__', $SubscriptionId) | Set-Content -Path $rulesFilePath

try {
    Import-AzSentinelDataConnector -SubscriptionId $SubscriptionId -WorkspaceName $Workspace -SettingsFile $rulesFilePath
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Error "Connector import failed with message: $ErrorMessage" 
}