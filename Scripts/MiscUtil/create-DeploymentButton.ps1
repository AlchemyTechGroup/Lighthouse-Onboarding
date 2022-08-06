$url = "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/marketplaceDelegatedResourceManagement.parameters.json"
$escapedurl = [uri]::EscapeDataString($url)


$formattedurl = "https://portal.azure.com/#create/Microsoft.Template/uri/"+$escapedurl

$markdown = "[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]($formattedurl)"

$html = @"
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/$formattedurl" target="_blank">
  <img src="https://aka.ms/deploytoazurebutton"/>
</a>
"@

Write-host "markdown:"
write-host $markdown


write-host
write-host
write-host "html:"
write-host $html