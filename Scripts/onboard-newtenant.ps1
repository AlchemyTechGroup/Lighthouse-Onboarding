$location = "southcentralus"
$customerName = "dlind"

new-azsubscriptiondeployment -name lh-atg-onboarding -location $location `
  -TemplateUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/onboarding/LHATGOnboarding.json `
  -customerName "$customerName" -verbose

  
New-AzDeployment -Name lh-atg-tags -location "southcentralus" `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/VMTags/VMTags.json"#> `
  -TemplateFile ..\templates\VMTags\VMTags2.json `
  -customerName $customerName -verbose

start-sleep(5000)
  
New-AzResourceGroupDeployment -Name lh-atg-tags -ResourceGroupName rg-vm-lh-atg-images `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/VMTags/VMTags.json"#> `
  -TemplateFile ..\templates\VMTags\VMTags.json `
  -customerName $customerName -verbose


& .\deploy-acg.ps1