#!/bin/bash

set -e

# Version to install
VERSION="v1.8.2"
BINARY_NAME="zarkham"
REPO="zarkhamVPN/binaries"

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE="linux";;
    Darwin*)    OS_TYPE="darwin";;
    *)          echo "Unsupported operating system: ${OS}"; exit 1;;
esac

# Detect Architecture
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)    ARCH_TYPE="amd64";;
    aarch64)   ARCH_TYPE="arm64";;
    arm64)     ARCH_TYPE="arm64";;
    *)         echo "Unsupported architecture: ${ARCH}"; exit 1;;
esac

# Construct Asset Name
# Format: linux-amd64-v1.8.2-alpha
ASSET_NAME="${OS_TYPE}-${ARCH_TYPE}-${VERSION}-alpha"

echo "ZARKHAM INSTALLER"
echo "----------------------"
echo "Detected: ${OS_TYPE} / ${ARCH_TYPE}"
echo "Target:   ${VERSION}"

# Download URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET_NAME}"

# Install Directory
INSTALL_DIR="/usr/local/bin"
TARGET_PATH="${INSTALL_DIR}/${BINARY_NAME}"

# Check permissions
if [ ! -w "$INSTALL_DIR" ]; then
    echo "⚠️  udo permissions required to install to ${INSTALL_DIR}"
    SUDO="sudo"
else
    SUDO=""
fi

echo "ownloading from: ${DOWNLOAD_URL}..."

# Download using curl
if command -v curl >/dev/null 2>&1; then
    $SUDO curl -L "${DOWNLOAD_URL}" -o "${TARGET_PATH}"
else
    echo "Error: curl is required."
    exit 1
fi

echo "🔒 Verifying integrity..."
# Basic check to see if we got a binary or an HTML error page
if grep -q "<html" "${TARGET_PATH}"; then
    echo "  Error: Download failed (404 Not Found or Access Denied)."
    echo "   Please check if release ${VERSION} exists on GitHub."
    $SUDO rm "${TARGET_PATH}"
    exit 1
fi

# Make executable
echo "Making executable..."
$SUDO chmod +x "${TARGET_PATH}"

echo ""
echo "✅ Installation Complete!"
echo "   Run 'zarkham' to start."
echo ""
