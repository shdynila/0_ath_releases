#!/bin/bash
set -e

CLIENT_BIN="./0ath_client"

# Check if it's already installed
if [ -x "$CLIENT_BIN" ]; then
    echo "Launching 0_ath Client..."
    $CLIENT_BIN
    exit 0
fi

echo "0_ath Client not found. Starting installation..."

OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$OS" = "Darwin" ]; then
    if [ "$ARCH" = "arm64" ]; then
        ASSET_NAME="mac-silicon"
    else
        ASSET_NAME="mac-intel"
    fi
elif [ "$OS" = "Linux" ]; then
    ASSET_NAME="linux"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

FILE_NAME="0ath_client_${ASSET_NAME}.zip"
DOWNLOAD_URL="https://github.com/shdynila/0_ath_releases/releases/latest/download/${FILE_NAME}"

echo "Downloading ${FILE_NAME} from latest release..."
curl -sSL -o "0ath_client.zip" "$DOWNLOAD_URL"

echo "Extracting..."
unzip -q -o 0ath_client.zip
rm 0ath_client.zip
chmod +x 0ath_client

echo "Installation complete! Launching game..."
./0ath_client
