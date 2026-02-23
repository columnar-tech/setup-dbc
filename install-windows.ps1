param(
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "Installing dbc CLI version: $Version"

try {
    # Download the official Windows install script
    $installScript = (Invoke-WebRequest -Uri "https://dbc.columnar.tech/install.ps1" -UseBasicParsing).Content

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

    # Verify installation
    $dbcPath = Get-Command dbc -ErrorAction SilentlyContinue
    if (-not $dbcPath) {
        Write-Error "dbc CLI installation failed - command not found"
        exit 1
    }

    # Output version for verification
    dbc --version

    Write-Host "dbc CLI installed successfully"
}
catch {
    Write-Error "Failed to install dbc CLI: $_"
    exit 1
}
