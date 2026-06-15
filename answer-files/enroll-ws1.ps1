
# WS1 Intelligent Hub installation and enrollment
# Device Services : ds2060.awmdm.com
# Group ID        : TAM_RDBa

$ErrorActionPreference = "Continue"

$HubInstaller = "C:\Temp\AirwatchAgent.msi"
$Server       = "ds2060.awmdm.com"
$GroupID      = "Windows_Staging"
$Username     = "stage"
$Password     = "stage123"



# Install and enroll Hub
Write-Host "Installing and enrolling Hub..."

$msiArgs = @(
    "/i", $HubInstaller,
    "/qn",
    "/norestart",
    "/l*v", "C:\Temp\hub_install.log",
    "ENROLL=Y",
    "SERVER=$Server",
    "LGName=$GroupID",
    "USERNAME=$Username",
    "PASSWORD=$Password",
    "ASSIGNTOLOGGEDINUSER=N"
)
# Explicitly wait for the msiexec process
& "C:\Windows\System32\msiexec.exe" @msiArgs
$msiProc = Get-Process -Name "msiexec" -ErrorAction SilentlyContinue
if ($msiProc) { $msiProc | Wait-Process }
Write-Host "msiexec exit code: $LASTEXITCODE"

# Wait until AirWatchMDMAgent service is running (max 15 minutes)
Write-Host "Waiting for WS1 Hub service..."
$timeout = 900
$elapsed = 0
$interval = 30

while ($elapsed -lt $timeout) {
    $service = Get-Service -Name "AirwatchService" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Write-Host "WS1 Hub service running after $elapsed seconds."
        break
    }
    Write-Host "[$elapsed/$timeout sec] Waiting for WS1 Hub..."
    Start-Sleep -Seconds $interval
    $elapsed += $interval
}

if ($elapsed -ge $timeout) {
    Write-Host "Timeout: WS1 Hub service did not start within $timeout seconds."
} else {
    Write-Host "WS1 enrollment completed."
}

# Remove temporary installation file
Remove-Item $HubInstaller -Force -ErrorAction SilentlyContinue

Write-Host "WS1 enrollment script done."

 New-Item -ItemType File -Path "C:\Temp\packer-ready.txt" -Force