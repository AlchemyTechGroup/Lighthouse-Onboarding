
$rgname = "rg-atg-acgallery"
new-azresourcegroup -name $rgname
New-AzResourceGroupDeployment -Name $rgname -ResourceGroupName rg-atg-acgallery `
  -TemplateUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/AzureGalleryImages/AzureGalleryDeployment.json `
  -TemplateParameterUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/AzureGalleryImages/AzureGalleryDeployment.parameters.json