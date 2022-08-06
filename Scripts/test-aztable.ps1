try {
    # Getting Azure context for the API call
    $null = select-azsubscription $env:homesubscription  | Out-Null
    $currentContext = Get-AzContext  | Out-Null

} catch {
    write-output "error: $error"
}