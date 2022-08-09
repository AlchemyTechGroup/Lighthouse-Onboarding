param (
  [Parameter( Mandatory=$true )]
  [string]$CustomerName
)
$rgname = "rg-kv-lh-atg-keyvault"
$paramfile = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/keyVaultDeployment.parameters.json' -Headers @{"Cache-Control"="no-cache"}

$newparameters = $paramfile.content -replace "ATGCustomerName", "$CustomerName"
$newparameters

$tempfile = "$($Env:TEMP)\$(new-guid).json"
add-content -path $tempfile -value $newparameters

New-AzResourceGroupDeployment -Name LH-ATG-KeyVault  -ResourceGroupName $rgname `
  -TemplateUri           'https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/keyVaultDeployment.json' `
  -TemplateParameterFile "$tempfile" `
  -verbose -whatif