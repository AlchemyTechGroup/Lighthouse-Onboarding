$location = "southcentralus"
$customerName = "dlind"


#$rgresponse = new-azsubscriptiondeployment -name lh-atg-onboarding -location $location `
#  -TemplateUri https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/onboarding/LHATGOnboarding.json `
#  -customerName "$customerName" -verbose

#$rgresponse

#if ($rgresponse.ProvisioningState -eq "succeeded") {
#  write-output "ResourceGroup creation suceeded"
#  write-output "pausing for 10 seconds"
#  start-sleep -seconds 10    
#}


#$tagresponse = New-AzDeployment -Name lh-atg-tags -location "southcentralus" `
#  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/VMTags/VMTagsCreation.json" #> `
#  -TemplateFile ..\..\templates\VMTags\VMTagsCreation.json `
#  -customerName "$customerName" -verbose

#$tagresponse

#if ($tagresponse.ProvisioningState -eq "succeeded") {
        
#  write-output "Tag Definition creation suceeded"
#  write-output "pausing for 10 seconds"
#  start-sleep -seconds 10    


#    $tagpolicyresponse = New-AzResourceGroupDeployment -Name lh-atg-tags-deploy -ResourceGroupName rg-vm-lh-atg-images `
#     <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/VMTags/VMTagsAssignment.json" #> `
#      -TemplateFile ..\..\templates\VMTags\VMTagsAssignment.json `
#      -verbose

#    $tagpolicyresponse  

#    if ($tagpolicyresponse.ProvisioningState -eq "succeeded") {      
#       write-output "Tag assignmednt creation suceeded"
#}


#& .\deploy-acg.ps1
#& .\deploy-kv.ps1 -CustomerName $customerName
& .\deploy-law.ps1 -CustomerName $customerName -logAnalytics '/subscriptions/f28acd55-79d1-49b7-a1ac-38e7939cf25f/resourcegroups/defaultresourcegroup-eus/providers/microsoft.operationalinsights/workspaces/workspace-0a61a6da-13ac-4417-a095-ce7495977127-eus'
