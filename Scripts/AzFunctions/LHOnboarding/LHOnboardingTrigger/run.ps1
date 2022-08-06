# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

if ($Timer.ScheduleStatus.Last -and $Timer.ScheduleStatus.Last -ne "0001-01-01T00:00:00Z") {
    $lastrun = $Timer.ScheduleStatus.Last
    $dateFormatForQuery = ($lastrun.ToUniversalTime()).addminutes(-5).ToString("yyyy-MM-ddTHH:mm:ssZ")
    #Write-Output "lastrundate: $lastrundate"
} else {
    $GetDate = (Get-Date).AddDays(-1)
    $dateFormatForQuery = $GetDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

if ($env:LHOnboarding_Override_Timer -eq "True") {
    $dateFormatForQuery = $env:LHOnboarding_Override_StartTime
}

$dateFormatNowForQuery = (get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
write-output "DateSt: $dateFormatForQuery"
write-output "DateEn: $dateFormatNowForQuery"

try {
# Getting Azure context for the API call
$null = select-azsubscription $env:homesubscription  | Out-Null
$currentContext = Get-AzContext  | Out-Null

# Fetching new token
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azureRmProfile)
$token = $profileClient.AcquireAccessToken($currentContext.Tenant.Id)

} 
catch {
    write-output "login not successful: Error $error"
}

#grab data from event provider
try {
    $listOperations = @{
        Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&`$filter=eventTimestamp ge '$($dateFormatForQuery)' and eventTimestamp le '$($dateFormatNowForQuery)' "
        Headers = @{
            Authorization  = "Bearer $($token.AccessToken)"
        }
        Method  = 'GET'
    }

    $list = Invoke-RestMethod @listOperations

} 
catch {
    write-output "api call not successful: Error $error"
}

# First link can be empty - and point to a next link (or potentially multiple pages)
# While you get more data - continue fetching and add result
$data = $list.value
while($list.nextLink){
    $list2 = Invoke-RestMethod $list.nextLink -Headers $listOperations.Headers -Method Get
    $data+=$list2.value;
    $list.nextLink = $list2.nextlink;
}

$showOperations = $data;
$showOperations = $showOperations | sort-object -property eventTimestamp 
write-output "count: $($data.count)"

Write-Output "Delegation events for tenant: $($currentContext.Tenant.TenantId)"

    $registerOutputs = $showOperations | Where-Object -FilterScript { $_.eventName.value -eq "EndRequest" -and $_.resourceType.value -and $_.operationName.value -like "Microsoft.Resources/tenants/*register/action"} 
    foreach ($registerOutput in $registerOutputs) {
        
        #Write-Output "----------------------------------------"
        #Write-Output $registerOutput
        #Write-Output "----------------------------------------"
        
        $eventDescription = $registerOutput.description | ConvertFrom-Json;
        if ($registerOutput.operationName.value -eq "Microsoft.Resources/tenants/register/action") { 
            $EventName = "An Azure customer has registered delegated resources to your Azure tenant";
        } elseif ($registerOutput.operationName.value -eq "Microsoft.Resources/tenants/unregister/action") {
            $EventName = "An Azure customer has unregistered delegated resources from your Azure tenant";
        }
        $registerOutputdata = [pscustomobject]@{
            Event                    = $EventName;
            DelegatedResourceId      = $eventDescription.delegationResourceId; 
            CustomerTenantId         = $eventDescription.subscriptionTenantId;
            CustomerSubscriptionId   = $eventDescription.subscriptionId;
            CustomerDelegationStatus = $registerOutput.status.value;
            EventTimeStamp           = $registerOutput.eventTimestamp;
        }
        $registerOutputdata | Format-List

        # write queue message to storage queue
        try {
            $outputMsg = $registerOutputdata
            Push-OutputBinding -name msg -Value $outputMsg
        } 
        catch 
        {
            write-output "storage queue add not successful: Error $error"
        }
    }

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
