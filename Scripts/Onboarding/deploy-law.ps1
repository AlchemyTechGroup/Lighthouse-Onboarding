param (
    [Parameter( Mandatory=$true )]
    [string]$CustomerName
  )
  $rgname = "rg-kv-lh-atg-keyvault"


New-AzDeployment -Name lh-atg-law -location "southcentralus" `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/LogAnalytics/omsExtensionPolicy.json" #> `
  -TemplateFile ..\..\templates\LogAnalytics\omsExtensionPolicy.json `
  -verbose

#write-output "pausing for 10 seconds"
#start-sleep -seconds 10
  
#New-AzResourceGroupDeployment -Name lh-atg-law-deployment -ResourceGroupName rg-vm-lh-atg-images `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/LogAnalytics/omsExtensionPolicyDeployment.json" #> `
#  -TemplateFile ..\..\templates\LogAnalytics\omsExtensionPolicyDeployment.json `
#  -verbose
