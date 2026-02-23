#!/bin/bash
set -euo pipefail

VERSION="${1:-latest}"

echo "Installing dbc CLI version: $VERSION"

# Download and run the official install script
# Note: Version flag (-v) support depends on the official install script
# If not supported, the script will install the latest version
if [ "$VERSION" = "latest" ]; then
  curl -fsSL https://dbc.columnar.tech/install.sh | bash
else
  export APP_VERSION="$VERSION"
  curl -fsSL https://dbc.columnar.tech/install.sh | bash -s
fi

# Verify installation
if ! command -v dbc &> /dev/null; then
  echo "::error::dbc CLI installation failed - command not found"
  exit 1
fi

# Output version for verification
dbc --version

echo "dbc CLI installed successfully"
