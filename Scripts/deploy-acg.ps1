
$rgname = "rg-atg-acgallery"
new-azresourcegroup -name $rgname
New-AzResourceGroupDeployment -Name LH-ATG-AzureComputeGallery  -ResourceGroupName $rgname `
  -TemplateUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/AzureGalleryImages/AzureGalleryDeployment.json `
  -TemplateParameterUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/AzureGalleryImages/AzureGalleryDeployment.parameters.json