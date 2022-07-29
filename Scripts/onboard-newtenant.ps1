$location = "southcentralus"
$customerName = "dlind"

new-azsubscriptiondeployment -name lh-atg-onboarding -location $location `
  -TemplateUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/onboarding/LHATGOnboarding.json `
  -customerName $customerName -location $location

New-AzSubscriptionDeployment -Name lh-atg-tags -Location $location `
  -TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/VMTags/VMTags.json" `
  -customerName $customerName -location $location