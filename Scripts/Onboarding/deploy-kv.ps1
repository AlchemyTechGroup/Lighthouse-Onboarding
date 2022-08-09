param (
  [Parameter( Mandatory=$true )]
  [string]$CustomerName
)
$rgname = "rg-kv-lh-atg-keyvault"
$paramfile = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/keyVaultDeployment.parameters.json'
$paramfile.content.gettype()

$paramfile.content | ConvertFrom-Json 

#New-AzResourceGroupDeployment -Name LH-ATG-KeyVault  -ResourceGroupName $rgname `
#  -TemplateUri          https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/KeyVaultDeployment.json `
#  -TemplateParameterUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/KeyVaultDeployment.parameters.json `
#  -verbose