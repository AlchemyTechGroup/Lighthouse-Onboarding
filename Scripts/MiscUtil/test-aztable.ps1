try {
    # Getting Azure context for the API call
    $null = select-azsubscription $env:homesubscription  | Out-Null
    $currentContext = Get-AzContext  | Out-Null

    $storageTable = Get-AzStorageTable –Name $tableName –Context $ctx
    $cloudTable = $storageTable.CloudTable

} catch {
    write-output "error: $error"
}