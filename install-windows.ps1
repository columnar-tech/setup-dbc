param(
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "Installing dbc CLI version: $Version"

try {
    # Download and run the official Windows install script
    if ($Version -eq "latest") {
        Invoke-Expression (Invoke-WebRequest -Uri "https://dbc.how/install.ps1" -UseBasicParsing).Content
    } else {
        # Pass version to install script if supported
        $installScript = (Invoke-WebRequest -Uri "https://dbc.how/install.ps1" -UseBasicParsing).Content
        Invoke-Expression "$installScript -Version $Version"
    }

    # Verify installation
    $dbcPath = Get-Command dbc -ErrorAction SilentlyContinue
    if (-not $dbcPath) {
        Write-Error "dbc CLI installation failed - command not found"
        exit 1
    }

    # Output version for verification
    dbc version

    Write-Host "dbc CLI installed successfully"
}
catch {
    Write-Error "Failed to install dbc CLI: $_"
    exit 1
}
