param (
    [Parameter( Mandatory=$false )]
    [string]$CustomerName
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

write-output "deploying policy definition"
$response = New-AzResourceGroupDeployment -Name lh-atg-law-deployment -ResourceGroupName $rgname `
  <#-TemplateUri "https://raw.githubusercontent.com/AlchemyTechGroup/Lighthouse-Onboarding/main/Templates/LogAnalytics/omsExtensionPolicyRemediation.json" #> `
  -TemplateFile ..\..\templates\LogAnalytics\omsExtensionPolicyRemediation.json `
  -workspaceKey (ConvertTo-SecureString -String "$primaryworkspacekey" -AsPlainText -Force) `
  -verbose

$response

if ($response.ProvisioningState -eq "succeeded") {
    write-output "Remediation task complete.  Check Azure for status."
}
