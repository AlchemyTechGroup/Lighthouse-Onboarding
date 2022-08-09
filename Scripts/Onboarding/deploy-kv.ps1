param (
  [Parameter( Mandatory=$false )]
  [string]$CustomerName
)
$rgname = "rg-acg-lh-atg-keyvault"
New-AzResourceGroupDeployment -Name LH-ATG-KeyVault  -ResourceGroupName $rgname `
  -TemplateUri          https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/KeyVaultDeployment.json `
  -TemplateParameterUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/KeyVault/KeyVaultDeployment.parameters.json `
  -customerName $CustomerName