param (
  [Parameter( Mandatory=$true )]
  [string]$CustomerName
)
$rgname = "rg-kv-lh-atg-keyvault"
$paramfile = Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"} -Uri 'https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/keyVaultDeployment.parameters.json' 
#$paramfile = get-content 'C:\Users\doug\source\repos\Lighthouse-Onboarding\Templates\KeyVault\keyVaultDeployment.parameters.json'

$newparameters = $paramfile.content -replace "ATGCustomerName", "$CustomerName"
#$newparameters = $paramfile -replace "ATGCustomerName", "$CustomerName"
$newparameters

$tempfile = "$($Env:TEMP)\$(new-guid).json"
add-content -path $tempfile -value $newparameters


$response = New-AzResourceGroupDeployment -Name LH-ATG-KeyVault  -ResourceGroupName $rgname `
  -TemplateUri           'https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/keyVaultDeployment.json' `
  -TemplateParameterFile "$tempfile" `
  -verbose #-whatif

$response

if ($response.ProvisioningState -eq "succeeded") {
        
  write-output "policy suceeded"
}