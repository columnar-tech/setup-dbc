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
        # Execute script with parameters
        # Note: -Version parameter support depends on the official install script
        # If not supported, the script will install the latest version
        if ($Version -eq "latest") {
            & $tempScript
        } else {
            & $tempScript -Version $Version
        }
    } finally {
        # Clean up temporary file
        Remove-Item -Path $tempScript -ErrorAction SilentlyContinue
    }

    # Add dbc installation directory to PATH
    $dbcInstallPath = Join-Path $env:USERPROFILE ".local\bin"
    if ((Test-Path $dbcInstallPath) -and ($env:Path -notlike "*$dbcInstallPath*")) {
        $env:Path = "$dbcInstallPath;$env:Path"
    }

    # Verify installation
    $dbcPath = Get-Command dbc -ErrorAction SilentlyContinue
    if (-not $dbcPath) {
        Write-Error "dbc CLI installation failed - command not found"
        exit 1
    }

    # Add to GitHub Actions PATH for subsequent steps (use actual location)
    if ($env:GITHUB_PATH) {
        $actualDbcDir = Split-Path -Parent $dbcPath.Source
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
