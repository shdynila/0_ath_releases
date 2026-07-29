$installDir = "C:\Games\0ath"
$clientBin = "$installDir\0ath_client.exe"

# Check if it's already installed
if (Test-Path -Path $clientBin) {
    Write-Host "Launching 0_ath Client..."
    Start-Process $clientBin
    exit
}

Write-Host "0_ath Client not found. Starting installation for Windows..."

$fileName = "0ath_client_windows.zip"
$downloadUrl = "https://github.com/shdynila/0_ath_releases/releases/latest/download/$fileName"

if (-Not (Test-Path -Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

$zipPath = "$installDir\$fileName"

Write-Host "Downloading latest release..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

Write-Host "Extracting to $installDir..."
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
Remove-Item $zipPath

Write-Host "Installation complete! Launching game..."
Start-Process $clientBin
