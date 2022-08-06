
# Variables
$AzureRmSubscriptionName = "MPN-VS-WVD subscription"
$RgName = "rg_atg_lh_dashboard"
$workbookDisplayName = "Azure Inventory"
$workbookSourceId = "Azure Monitor"
$workbookType = "workbook"
$templateUri = "https://raw.githubusercontent.com/scautomation/Azure-Inventory-Workbook/master/armTemplate/template.json"
$workbookSerializedData = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/scautomation/Azure-Inventory-Workbook/master/galleryTemplate/template.json"

## Connectivity
# Login first with Connect-AzAccount if not using Cloud Shell
#$AzureRmContext = Get-AzSubscription -SubscriptionName $AzureRmSubscriptionName | Set-AzContext -ErrorAction Stop
#Select-AzSubscription -Name $AzureRmSubscriptionName -Context $AzureRmContext -Force -ErrorAction Stop

## Action
Write-Host "Deploying : $workbookType-$workbookDisplayName in the resource group : $RgName" -ForegroundColor Cyan
New-AzResourceGroupDeployment -Name $(("$workbookType-$workbookDisplayName").replace(' ', '')) -ResourceGroupName $RgName `
  -TemplateUri $TemplateUri `
  -workbookDisplayName $workbookDisplayName `
  -workbookType $workbookType `
  -workbookSourceId $workbookSourceId `
  -Confirm -ErrorAction Stop
