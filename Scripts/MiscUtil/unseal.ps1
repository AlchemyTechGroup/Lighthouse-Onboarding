$unSealScriptBlock = {
    $reg_path = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
    get-itemproperty $reg_path
    
    if (-Not (Test-Path $reg_path)) { New-Item $reg_path -Force }
    Set-ItemProperty $reg_path -Name NoAutoUpdate -Value 0
    Set-ItemProperty $reg_path -Name AUOptions -Value 4
    $reg_path = "HKLM:\Software\Policies\Microsoft\Windows\Task Scheduler\Maintenance"
    if (-Not (Test-Path $reg_path)) { New-Item $reg_path -Force }
    Set-ItemProperty $reg_path -Name "Activation Boundary" -Value "2000-01-01T01:00:00"
    Set-ItemProperty $reg_path -Name Randomized -Value 1
    Set-ItemProperty $reg_path -Name "Random Delay" -Value "PT4H"
    $service = "wuauserv"
    $winUpdateSvc = Get-Service $service
    if ($winUpdateSvc.StartupType -notmatch "Automatic") {set-service $service -StartupType Automatic}    
    if ($winUpdateSvc.Status -notmatch "Running") {start-service $service}
    start-process -filepath "$($env:systemroot)\system32\usoclient.exe" -args "startscan"
}