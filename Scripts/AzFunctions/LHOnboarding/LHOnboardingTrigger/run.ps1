# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

$lastrun = $Timer.ScheduleStatus.Last
write-host "timer: $Timer"
Timer.


$GetDate = (Get-Date).AddDays(-7)

$dateFormatForQuery = $GetDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$dateFormatNowForQuery = (get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
write-output "Date: $dateFormatForQuery"

try {
# Getting Azure context for the API call
select-azsubscription "f28acd55-79d1-49b7-a1ac-38e7939cf25f"
$currentContext = Get-AzContext

# Fetching new token
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azureRmProfile)
$token = $profileClient.AcquireAccessToken($currentContext.Tenant.Id)

} 
catch {
    write-output "login not successful: Error $error"
}

try {
$listOperations = @{
    Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&`$filter=eventTimestamp ge '$($dateFormatForQuery)' and eventTimestamp le '$($dateFormatNowForQuery)' "
    #Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&`$filter=eventTimestamp ge '$($dateFormatForQuery)' and eventTimestamp le '$($dateFormatNowForQuery)' and eventChannels eq 'Admin, Operation' and resourceProvider eq 'Microsoft.Resources'"
    #Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&`$filter=eventTimestamp ge '$($dateFormatForQuery)'"
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
while($list.nextLink){
    $list2 = Invoke-RestMethod $list.nextLink -Headers $listOperations.Headers -Method Get
    $data+=$list2.value;
    $list.nextLink = $list2.nextlink;
}


$showOperations = $data;


#write-output "count: $($data.count)"
#$showOperations.operationName.value


Write-Output "Delegation events for tenant: $($currentContext.Tenant.TenantId)"

if ($showOperations.operationName.value -eq "Microsoft.Resources/tenants/register/action") {
    $registerOutputs = $showOperations | Where-Object -FilterScript { $_.eventName.value -eq "EndRequest" -and $_.resourceType.value -and $_.operationName.value -eq "Microsoft.Resources/tenants/register/action" }
    foreach ($registerOutput in $registerOutputs) {
            $eventDescription = $registerOutput.description | ConvertFrom-Json;
            $registerOutputdata = [pscustomobject]@{
            Event                    = "An Azure customer has registered delegated resources to your Azure tenant";
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

        <#
        # write law message to analytics for alerting
        try {
            $writeLAWOperations = @{
                Uri     = "https://prod-39.eastus2.logic.azure.com:443/workflows/b2f968f2238c4d9e8e11ae0846d85652/triggers/request/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Frequest%2Frun&sv=1.0&sig=J_B_uerBC5n1UXONJO28InqkbgAffLU4go7V0suXfuI"
                Headers = @{
                    'Content-Type' = "application/json"
                    'TenantID'  = "ATG"
                }
                Method  = 'POST'
                Body = $registerOutputdata | convertto-json
            }
            Invoke-RestMethod @writeLAWOperations
        } 
        catch 
        {
            write-output "LAW add not successful: Error $error"
        }

        #>

    }
} else {
    write-output "no new registrations"
}
if ($showOperations.operationName.value -eq "Microsoft.Resources/tenants/unregister/action") {
    $unregisterOutputs = $showOperations | Where-Object -FilterScript { $_.eventName.value -eq "EndRequest" -and $_.resourceType.value -and $_.operationName.value -eq "Microsoft.Resources/tenants/unregister/action" }
    foreach ($unregisterOutput in $unregisterOutputs) {
            $eventDescription = $registerOutput.description | ConvertFrom-Json;
            $unregisterOutputdata = [pscustomobject]@{
            Event                    = "An Azure customer has unregistered delegated resources from your Azure tenant";
            DelegatedResourceId      = $eventDescription.delegationResourceId;
            CustomerTenantId         = $eventDescription.subscriptionTenantId;
            CustomerSubscriptionId   = $eventDescription.subscriptionId;
            CustomerDelegationStatus = $unregisterOutput.status.value;
            EventTimeStamp           = $unregisterOutput.eventTimestamp;
        }
        $unregisterOutputdata | Format-List

        # write queue message to storage queue
        try {
            $outputMsg = $unregisterOutputdata
            Push-OutputBinding -name msg -Value $outputMsg
        } 
        catch 
        {
            write-output "storage queue add not successful: Error $error"
        }

        <#
        # write law message to analytics for alerting
        try {
            $writeLAWOperations = @{
                Uri     = "https://prod-39.eastus2.logic.azure.com:443/workflows/b2f968f2238c4d9e8e11ae0846d85652/triggers/request/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Frequest%2Frun&sv=1.0&sig=J_B_uerBC5n1UXONJO28InqkbgAffLU4go7V0suXfuI"
                Headers = @{
                    'Content-Type' = "application/json"
                    'TenantID'  = "ATG"
                }
                Method  = 'POST'
                Body = $unregisterOutputdata | convertto-json
            }
            Invoke-RestMethod @writeLAWOperations
        } 
        catch 
        {
            write-output "LAW add not successful: Error $error"
        }
        #>
    }
} else {
    write-output "no new unregistrations"
}


<#


$body = @"
{
    Event: "An Azure customer has registered delegated resources to your Azure tenant",
    DelegatedResourceId: "8b77715f-9f75-4358-bca4-a9eb49c2c4fb",
    CustomerTenantId: "ffdadd88-6fea-45cb-bc14-29ab716d050f",
    CustomerSubscriptionId: "ba597ea9-e4b1-4ef0-9aa9-80da6a5dd5c7",
    CustomerDelegationStatus: "34929422-3c03-4942-9baa-1bfb541ac6e7",
    EventTimeStamp: "2022-07-29T21:54:24.6925846Z"
}
"@

$writeOperations = @{
    Uri     = "https://prod-39.eastus2.logic.azure.com:443/workflows/b2f968f2238c4d9e8e11ae0846d85652/triggers/request/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Frequest%2Frun&sv=1.0&sig=J_B_uerBC5n1UXONJO28InqkbgAffLU4go7V0suXfuI"
    Headers = @{
        'Content-Type' = "application/json"
        'TenantID'  = "ATG"
    }
    Method  = 'POST'
    Body = $body
}


Invoke-RestMethod @writeOperations


#>



# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
