$location = "southcentralus"
$customerName = "dlind"

#new-azsubscriptiondeployment -name lh-atg-onboarding -location $location `
#  -TemplateUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/onboarding/LHATGOnboarding.json `
#  -customerName "$customerName" -verbose

#write-output "pausing for 10 seconds"
#start-sleep -seconds 10

#New-AzDeployment -Name lh-atg-tags -location "southcentralus" `
#  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/VMTags/VMTagsCreation.json" #> `
#  -TemplateFile ..\..\templates\VMTags\VMTagsCreation.json `
#  -customerName "$customerName" -verbose

#write-output "pausing for 10 seconds"
#start-sleep -seconds 10
  
#New-AzResourceGroupDeployment -Name lh-atg-tags -ResourceGroupName rg-vm-lh-atg-images `
#  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/VMTags/VMTagsAssignment.json" #> `
#  -TemplateFile ..\..\templates\VMTags\VMTagsAssignment.json `
#  -verbose


#& .\deploy-acg.ps1
#& .\deploy-kv.ps1 -CustomerName $customerName
& .\deploy-law.ps1 -CustomerName $customerName
