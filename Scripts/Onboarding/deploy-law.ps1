param (
    [Parameter( Mandatory=$true )]
    [string]$CustomerName,
    [Parameter( Mandatory=$true )]
    [string]$logAnalytics
  )
$rgname = "rg-vm-lh-atg-images"

write-output "saving azcontext"
$azContext = get-azcontext


write-output "grabbing workspace key"
$mute = select-AzSubscription -SubscriptionId f28acd55-79d1-49b7-a1ac-38e7939cf25f
$primaryworkspacekey = (get-azoperationalinsightsworkspace -DefaultProfile $mute | Where-Object { $_.name -eq "Workspace-0a61a6da-13ac-4417-a095-ce7495977127-EUS" } | Get-AzOperationalInsightsWorkspaceSharedKey).PrimarySharedKey

write-output "reset azcontext"
set-azcontext -context $azContext

#pause

#write-output "deploying policy definition"
#$response = New-AzDeployment -Name lh-atg-law -location "southcentralus" -logAnalytics $logAnalytics -ResourceGroupName $rgname `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/LogAnalytics/omsExtensionPolicy.json" #> `
#  -TemplateFile ..\..\templates\LogAnalytics\omsExtensionPolicy.json `
#  -verbose

#$response

#if ($response.ProvisioningState -eq "succeeded") {
    
    write-output "assigning policy; pausing for 10 seconds"
#    start-sleep -seconds 10

    New-AzResourceGroupDeployment -Name lh-atg-law-deployment -ResourceGroupName $rgname `
    <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/LogAnalytics/omsExtensionPolicyDeployment.json" #> `
    -TemplateFile ..\..\templates\LogAnalytics\omsExtensionPolicyDeployment.json `
    -workspaceKey (ConvertTo-SecureString -String "$primaryworkspacekey" -AsPlainText -Force) `
    -verbose
#}
