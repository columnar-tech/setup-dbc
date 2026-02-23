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

    # Verify installation
    $dbcPath = Get-Command dbc -ErrorAction SilentlyContinue
    if (-not $dbcPath) {
        Write-Error "dbc CLI installation failed - command not found"
        exit 1
    }

    # Get actual dbc installation directory
    $actualDbcDir = Split-Path -Parent $dbcPath.Source

    # Add actual dbc directory to session PATH
    if ($env:Path -notlike "*$actualDbcDir*") {
        $env:Path = "$actualDbcDir;$env:Path"
    }

    # Add to GitHub Actions PATH for subsequent steps
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
