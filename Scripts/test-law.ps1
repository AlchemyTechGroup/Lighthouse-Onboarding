
$body = @"
{
    Event: "An Azure customer has registered delegated resources to your Azure tenant",
    DelegatedResourceId: "8b77715f-9f75-4358-bca4-a9eb49c2c4fb",
    CustomerTenantId: "ffdadd88-6fea-45cb-bc14-29ab716d050f",
    CustomerSubscriptionId: "ba597ea9-e4b1-4ef0-9aa9-80da6a5dd5c7",
    CustomerDelegationStatus: "34929422-3c03-4942-9baa-1bfb541ac6e7",
    EventTimeStamp: "2022-08-04T21:54:24.6925846Z"
}
"@

$listOperations = @{
    Uri     = "https://prod-39.eastus2.logic.azure.com:443/workflows/b2f968f2238c4d9e8e11ae0846d85652/triggers/request/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Frequest%2Frun&sv=1.0&sig=J_B_uerBC5n1UXONJO28InqkbgAffLU4go7V0suXfuI"
    Headers = @{
        'Content-Type' = "application/json"
        'TenantID'  = "ATG"
    }
    Method  = 'POST'
    Body = $body
}


Invoke-RestMethod @listOperations
