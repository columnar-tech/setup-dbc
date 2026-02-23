param(
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "Installing dbc CLI version: $Version"

try {
    # Download the official Windows install script
    $response = Invoke-WebRequest -Uri "https://dbc.columnar.tech/install.ps1" -UseBasicParsing
    # Handle both PowerShell Core (byte[]) and Windows PowerShell 5.1 (string)
    if ($response.Content -is [byte[]]) {
        $installScript = [System.Text.Encoding]::UTF8.GetString($response.Content)
    } else {
        $installScript = $response.Content
    }

    # Save to temporary file to avoid Invoke-Expression security risks
    $tempScript = Join-Path $env:TEMP "dbc-install-$(Get-Random).ps1"
    $installScript | Out-File -FilePath $tempScript -Encoding UTF8

    try {
        # Execute script with version via environment variable
        # Note: Version is passed via APP_VERSION environment variable
        # If the official install script doesn't support it, latest version will be installed
        if ($Version -ne "latest") {
            $env:APP_VERSION = $Version
        }
        & $tempScript
    } finally {
        # Clean up temporary file
        Remove-Item -Path $tempScript -ErrorAction SilentlyContinue
    }

    # Try to find dbc - first check expected location directly
    $expectedDbcPath = Join-Path (Join-Path $env:USERPROFILE ".local\bin") "dbc.exe"
    if (Test-Path $expectedDbcPath) {
        $expectedDir = Split-Path -Parent $expectedDbcPath
        $pathEntries = $env:Path -split ';' | ForEach-Object { $_.TrimEnd('\') }
        $expectedDirNormalized = $expectedDir.TrimEnd('\')
        if ($pathEntries -notcontains $expectedDirNormalized) {
            $env:Path = "$expectedDir;$env:Path"
        }
    }

    # Verify installation and get actual location
    $dbcPath = Get-Command dbc -ErrorAction SilentlyContinue
    if (-not $dbcPath) {
        Write-Error "dbc CLI installation failed - command not found"
        exit 1
    }

    # Ensure actual location is in session PATH (may differ from expected)
    $actualDbcDir = Split-Path -Parent $dbcPath.Source
    $pathEntries = $env:Path -split ';' | ForEach-Object { $_.TrimEnd('\') }
    $actualDbcDirNormalized = $actualDbcDir.TrimEnd('\')
    if ($pathEntries -notcontains $actualDbcDirNormalized) {
        $env:Path = "$actualDbcDir;$env:Path"
    }

    # Add actual location to GitHub Actions PATH
    if ($env:GITHUB_PATH) {
        $actualDbcDir | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
    }

    # Output version for verification
    dbc --version

    Write-Host "dbc CLI installed successfully"
}
catch {
    Write-Error "Failed to install dbc CLI: $_"
    exit 1
}
