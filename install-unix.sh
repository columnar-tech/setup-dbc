#!/bin/bash
set -euo pipefail

VERSION="${1:-latest}"

echo "Installing dbc CLI version: $VERSION"

# Download and run the official install script
# Note: Version is passed via APP_VERSION environment variable
# If the official install script doesn't support it, latest version will be installed
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
