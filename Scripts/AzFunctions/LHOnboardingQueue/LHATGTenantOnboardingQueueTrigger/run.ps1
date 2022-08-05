# Input bindings are passed in via param block.
param($QueueItem, $TriggerMetadata)

# Write out the queue message and insertion time to the information log.
Write-Output "Queue trigger function for Tenant Onboarding processed the following:"
write-output "Event: $($QueueItem.Event)"
write-output "DelegatedResourceId: $($QueueItem.DelegatedResourceId)"
write-output "CustomerTenantId: $($QueueItem.CustomerTenantId)"
write-output "CustomerSubscriptionId: $($QueueItem.CustomerSubscriptionId)"
write-output "CustomerDelegationStatus: $($QueueItem.CustomerDelegationStatus)"
write-output "EventTimeStamp: $($QueueItem.EventTimeStamp)"

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
Write-Output "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
