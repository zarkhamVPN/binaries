#!/bin/bash

set -e

BINARY_NAME="zarkham"
REPO="zarkhamVPN/binaries"

echo "ZARKHAM INSTALLER"
echo "----------------------"

echo "Checking for latest release..."

API_URL="https://api.github.com/repos/${REPO}/releases/latest"
LATEST_VERSION=$(curl -s "${API_URL}" | grep '"tag_name":' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo "Could not fech latest version (API limit or network). Defaulting to v1.8.2"
    VERSION="v1.8.2"
else
    VERSION=$LATEST_VERSION
fi

OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE="linux";;
    Darwin*)    OS_TYPE="darwin";;
    *)          echo "Unsupported operating system: ${OS}"; exit 1;;
esac

ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)    ARCH_TYPE="amd64";;
    aarch64)   ARCH_TYPE="arm64";;
    arm64)     ARCH_TYPE="arm64";;
    *)         echo "Unsupported architecture: ${ARCH}"; exit 1;;
esac

ASSET_NAME="${OS_TYPE}-${ARCH_TYPE}-${VERSION}-alpha"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET_NAME}"

echo "Detected: ${OS_TYPE} / ${ARCH_TYPE}"
echo "Target:   ${VERSION}"

INSTALL_DIR="/usr/local/bin"
TARGET_PATH="${INSTALL_DIR}/${BINARY_NAME}"

if [ ! -w "$INSTALL_DIR" ]; then
    echo "sudo permissions required to install to ${INSTALL_DIR}"
    SUDO="sudo"
else
    SUDO=""
fi

if [ -f "$TARGET_PATH" ]; then
    echo "Updating existing installation..."
    $SUDO rm -f "$TARGET_PATH"
fi

echo "Downloading from: ${DOWNLOAD_URL}..."
$SUDO curl -L "${DOWNLOAD_URL}" -o "${TARGET_PATH}"

FILE_SIZE=$($SUDO wc -c < "${TARGET_PATH}")
FILE_SIZE="${FILE_SIZE// /}"

if [ "$FILE_SIZE" -lt 1000000 ]; then
    echo "Error: Download too small (<1MB). Likely an error page."
    $SUDO head -n 5 "${TARGET_PATH}"
    $SUDO rm "${TARGET_PATH}"
    exit 1
fi

echo "Making executable..."
$SUDO chmod +x "${TARGET_PATH}"

echo "Initializing configuration..."
mkdir -p "$HOME/.zarkham/config"

echo ""
echo "Zarkham ${VERSION} Installed Successfully!"
echo "   Visit https://docs.zarkham.xyz for further steps."
echo ""
