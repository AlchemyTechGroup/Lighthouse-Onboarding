
$body = @"
{ "input": "test" }
"@

$listOperations = @{
    Uri     = "https://lhatgtenantonboarding.azurewebsites.net/admin/functions/LHOnboardingTrigger"
    Headers = @{
        'Content-Type' = "application/json"
        'x-functions-key' = "quhS5XdIYPbF938NYKQ6hkojB3H7wManFnv2B7ne2uw7AzFuQMDGaw=="
    }
    Method  = 'POST'
    Body = $body
}


Invoke-RestMethod @listOperations
