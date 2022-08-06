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

#querying for existing table storage item
$row = $null
try {
    $ctx = New-AzStorageContext -ConnectionString $env:AzureWebJobsStorage
    $cloudtable = (Get-AzStorageTable -Context $ctx -name lhtenants).cloudtable

    #$tablerow = Get-AzTableRow -table $cloudTable -partitionKey $QueueItem.CustomerTenantId -rowkey $QueueItem.CustomerSubscriptionId 

    $row = get-AzTableRow -Table $cloudtable -partitionKey $QueueItem.CustomerTenantId -rowkey $QueueItem.CustomerSubscriptionId 
} catch {
    Write-Output "error: $error"
}

write-output "`nAttempting table storage actions"
# write to table for storage
$attemptlawaction = $null
try {
    $attemptlawaction = $null
    $tableaction = $null

    if ($QueueItem.Event -eq "An Azure customer has registered delegated resources to your Azure tenant") {
        $action = "onboarded"
        if ($action -eq $row.action ) {
            #already onboarded, duplicate action
            write-output "duplicated action, skipping"
            $tableaction = "nothing"
        } elseif ("removed" -eq $row.action) {
            #reprovisioning an already existing subscription - adding to table
            write-output "reprovisioning existing removed delegation..."
            $tableaction = "update"
        } else {
            #new action - process accordingly
            write-output "adding new delegation..."
            $tableaction = "add"
        }


    } elseif ($QueueItem.Event -eq "An Azure customer has unregistered delegated resources from your Azure tenant") {
        $action = "removed"
        if ($action -eq $row.action ) {
            #already removed, duplicate action
            write-output "duplicated action, skipping"
            $tableaction = "nothing"
        } elseif ("onboarded" -eq $row.action) {
            #deprovisioning an existing subscription - updating table
            write-output "removing delegation..."
            $tableaction = "remove"
        } else {
            #bad action - alert
            write-output "bad action, trying to remove a delegation that doesn't exist..."
            $tableaction = "nothing"
        }
    }

    $outval = @{
        DelegatedResourceId = "$($QueueItem.DelegatedResourceId)"
        Action = $action
        CustomerDelegationStatus = "$($QueueItem.CustomerDelegationStatus)"
        EventTimeStamp = "$($QueueItem.EventTimeStamp)"
    }

    switch ($action) {
    
        "update" {
            #update existing table row
            $row.action = $action
            $row.EventTimeStamp = $QueueItem.EventTimeStamp
            $row | update-aztablerow -table $cloudtable
            $attemptlawaction = 1
            break; }
        "add" {
            #add table row
            Add-AzTableRow `
                -table $cloudTable `
                -partitionKey $QueueItem.CustomerTenantId `
                -rowKey $QueueItem.CustomerSubscriptionId 
                -property $outval
            $attemptlawaction = 1
            break; }
        "remove" {
            #remove (deprovisoin) existing table row
            $row.action = $action
            $row.EventTimeStamp = $QueueItem.EventTimeStamp
            $row | update-aztablerow -table $cloudtable
            $attemptlawaction = 1
            break; }
        "nothing" {
            <#take no action#>
            break; }
    }
    

    #return = Push-OutputBinding -name LHTenantsTable -Value $outval -ErrorAction:Stop
    #write-output "return: $return"
    
} 
catch 
{
    write-output "storage queue add not successful: Error $error"
    write-output "errorname: $($Error[0].Exception.GetType().FullName)"
}

if ($attemptlawaction) {
    write-output "`nAttempting law actions"
    # write law message to analytics for alerting
    try {
        $writeLAWOperations = @{
            Uri     = "https://prod-39.eastus2.logic.azure.com:443/workflows/b2f968f2238c4d9e8e11ae0846d85652/triggers/request/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Frequest%2Frun&sv=1.0&sig=J_B_uerBC5n1UXONJO28InqkbgAffLU4go7V0suXfuI"
            Headers = @{
                'Content-Type' = "application/json"
                'TenantID'  = "ATG"
            }
            Method  = 'POST'
            Body = $QueueItem | ConvertTo-Json
        }
        $response = Invoke-RestMethod @writeLAWOperations
        write-output "law submitted; response: $response"
    } 
    catch 
    {
        write-output "LAW add not successful: Error $error"
    }

}
Write-Output "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
