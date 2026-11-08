#!/data/data/com.termux/files/usr/bin/bash
set -e
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
DEST="$PREFIX/bin/hexmenu"
URL="https://raw.githubusercontent.com/khahdihdz/hexmenu/main/hexmenu.sh"

if ! command -v curl >/dev/null 2>&1; then
  pkg install -y curl
fi
if ! command -v openssl >/dev/null 2>&1; then
  pkg install -y openssl
fi
mkdir -p "$PREFIX/bin"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$URL" -o "$tmp"
bash -n "$tmp"
install -m 755 "$tmp" "$DEST"
echo "Cài đặt HEX MENU thành công!"
echo "Mở menu bằng lệnh: hexmenu"
