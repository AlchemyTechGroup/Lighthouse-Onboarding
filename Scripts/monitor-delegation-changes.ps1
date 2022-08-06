# Log in first with Connect-AzAccount if you're not using Cloud Shell

# Azure Lighthouse: Query Tenant Activity Log for registered/unregistered delegations for the last 1 day

$GetDate = (Get-Date).addhours(-1)

$dateFormatForQuery = $GetDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$dateFormatNowForQuery = (get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$dateFormatForQuery = "2022-08-06T01:30:00Z"
write-output "Date: $dateFormatForQuery"
write-output "nowDate: $dateFormatNowForQuery"



# Getting Azure context for the API call
select-azsubscription "f28acd55-79d1-49b7-a1ac-38e7939cf25f" | Out-Null
$currentContext = Get-AzContext

# Fetching new token
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azureRmProfile)
$token = $profileClient.AcquireAccessToken($currentContext.Tenant.Id)
#write-output "token: $($token.AccessToken)"

$listOperations = @{
    
    #Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&`$filter=eventTimestamp%20ge%20%272022-07-24T17%3A03%3A13Z%27%20and%20eventTimestamp%20le%20%272022-07-30T23%3A03%3A13Z%27%20and%20eventChannels%20eq%20%27Admin%2C%20Operation%27%20and%20resourceProvider%20eq%20%27Microsoft.Resources%27"
    #Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&`$filter=eventTimestamp ge '$($dateFormatForQuery)' and eventTimestamp le '$($dateFormatNowForQuery)' and eventChannels eq 'Admin, Operation' and resourceProvider eq 'Microsoft.Resources'"
    #Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&%24filter=eventTimestamp%20ge%20'2022-07-24T17%3A03%3A13Z'%20and%20eventTimestamp%20le%20'2022-07-30T23%3A03%3A13Z'%20and%20eventChannels%20eq%20'Admin%2C%20Operation'%20and%20resourceProvider%20eq%20'Microsoft.Resources'"
    Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&`$filter=eventTimestamp ge '$($dateFormatForQuery)' and eventTimestamp le '$($dateFormatNowForQuery)'"
    #Uri     = "https://management.azure.com/providers/microsoft.insights/eventtypes/management/values?api-version=2015-04-01&%24filter=eventTimestamp%20ge%20%272022-08-05T00%3A00%3A00Z%27"
    
    Headers = @{
        Authorization  = "Bearer $($token.AccessToken)"
    }
    Method  = 'GET'
}

Write-Output $listOperations.Uri

$list = Invoke-RestMethod @listOperations
<#
write-output "----------------------------------------------------------------------------------------------------"
write-output "nextlink: $($list.nextlink)"
$list.value.operationName.value
#$list.value | fl *
write-output "----------------------------------------------------------------------------------------------------"
#>

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
    }
