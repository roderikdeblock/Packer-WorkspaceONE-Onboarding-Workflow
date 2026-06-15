# SetupComplete script — runs automatically after OOBE
# Handles VMware Tools installation and WinRM reconfiguration

# Set network to Private
Set-NetConnectionProfile -NetworkCategory Private

# Reconfigure WinRM — in case it was reset after OOBE
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=Yes

# Keep Administrator account active
net user Administrator Packer1234! /active:yes


Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "EnrollWS1" -Value "PowerShell.exe -ExecutionPolicy Bypass -File C:\Temp\enroll-ws1.ps1"

# Install VMware Tools — automatically find the correct drive letter
$drives = Get-WmiObject Win32_CDROMDrive
foreach ($drive in $drives) {
    $letter = $drive.Drive
    if (Test-Path "$letter\setup.exe") {
        Write-Host "VMware Tools found on $letter"
        Start-Process "$letter\setup.exe" -ArgumentList '/S /v "/qn REBOOT=R"' -Wait
        break
    }
}

Write-Host "SetupComplete done."
