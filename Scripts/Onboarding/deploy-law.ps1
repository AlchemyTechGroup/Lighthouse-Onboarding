param (
    [Parameter( Mandatory=$true )]
    [string]$CustomerName,
    [Parameter( Mandatory=$true )]
    [string]$logAnalytics
  )
  $rgname = "rg-vm-lh-atg-images"


New-AzDeployment -Name lh-atg-law -location "southcentralus" -logAnalytics $logAnalytics -ResourceGroupName $rgname `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/LogAnalytics/omsExtensionPolicy.json" #> `
  -TemplateFile ..\..\templates\LogAnalytics\omsExtensionPolicy.json `
  -verbose

write-output "pausing for 10 seconds"
start-sleep -seconds 10

  
New-AzResourceGroupDeployment -Name lh-atg-law-deployment -ResourceGroupName $rgname `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/LogAnalytics/omsExtensionPolicyDeployment.json" #> `
  -TemplateFile ..\..\templates\LogAnalytics\omsExtensionPolicyDeployment.json `
  -verbose
