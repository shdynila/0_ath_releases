#!/bin/bash
set -e

CLIENT_DIR="./0ath"
CLIENT_BIN="$CLIENT_DIR/0ath_client"
VERSION_FILE="$CLIENT_DIR/version.txt"

launch_game() {
    cd "$CLIENT_DIR"
    while true; do
        ./0ath_client
        
        if [ -f "session.json" ]; then
            # Use basic grep/sed to extract userId and jwt without depending on jq
            USER_ID=$(grep -o '"username":"[^"]*"' session.json | sed 's/"username":"\([^"]*\)"/\1/' || true)
            if [ -z "$USER_ID" ]; then
                USER_ID=$(grep -o '"userId":"[^"]*"' session.json | sed 's/"userId":"\([^"]*\)"/\1/' || true)
            fi
            JWT=$(grep -o '"jwt":"[^"]*"' session.json | sed 's/"jwt":"\([^"]*\)"/\1/' || true)
            
            rm -f session.json
            
            if [ -n "$USER_ID" ]; then
                echo "Session detected! Launching game client..."
                
                ARGS=("-login-id" "$USER_ID")
                if [ -n "$JWT" ]; then
                    ARGS+=("-jwt" "$JWT")
                fi
                
                ./0ath_client "${ARGS[@]}"
            fi
            break
        else
            break
        fi
    done
    cd ..
}

echo "Checking for updates..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/shdynila/0_ath_releases/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

LOCAL_VERSION=""
if [ -f "$VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$VERSION_FILE")
fi

if [ -x "$CLIENT_BIN" ] && [ "$LOCAL_VERSION" = "$LATEST_RELEASE" ] && [ -n "$LATEST_RELEASE" ]; then
    echo "0_ath Client is up to date ($LOCAL_VERSION). Launching..."
    launch_game
    exit 0
fi

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

mkdir -p "$CLIENT_DIR"
cd "$CLIENT_DIR"

if [ -n "$LOCAL_VERSION" ]; then
    echo "Updating from $LOCAL_VERSION to $LATEST_RELEASE..."
else
    echo "Starting installation (Release $LATEST_RELEASE)..."
fi

curl -sSL -o "0ath_client.zip" "$DOWNLOAD_URL"
unzip -q -o 0ath_client.zip
rm 0ath_client.zip
chmod +x 0ath_client

if [ -n "$LATEST_RELEASE" ]; then
    echo "$LATEST_RELEASE" > version.txt
fi

cd ..
echo "Update complete! Launching game..."
launch_game
