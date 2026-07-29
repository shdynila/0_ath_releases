$installDir = "C:\Games\0ath"
$clientBin = "$installDir\0ath_client.exe"
$versionFile = "$installDir\version.txt"
$fileName = "0ath_client_windows.zip"
$downloadUrl = "https://github.com/shdynila/0_ath_releases/releases/latest/download/$fileName"

Write-Host "Checking for updates..."
try {
    $releaseApi = "https://api.github.com/repos/shdynila/0_ath_releases/releases/latest"
    $latestRelease = (Invoke-RestMethod -Uri $releaseApi -UseBasicParsing).tag_name
} catch {
    $latestRelease = "unknown"
}

$localVersion = ""
if (Test-Path -Path $versionFile) {
    $localVersion = Get-Content -Path $versionFile
}

if ((Test-Path -Path $clientBin) -and ($localVersion -eq $latestRelease) -and ($latestRelease -ne "unknown")) {
    Write-Host "0_ath Client is up to date ($localVersion). Launching..."
    Start-Process $clientBin
    exit
}

if (-Not (Test-Path -Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

if ($localVersion -ne "") {
    Write-Host "Updating from $localVersion to $latestRelease..."
} else {
    Write-Host "Starting installation for Windows (Release $latestRelease)..."
}

$zipPath = "$installDir\$fileName"
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
Remove-Item $zipPath
if ($latestRelease -ne "unknown") {
    Set-Content -Path $versionFile -Value $latestRelease
}

Write-Host "Update complete! Launching game..."
Start-Process $clientBin
