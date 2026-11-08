#!/data/data/com.termux/files/usr/bin/bash
# HEX MENU - OpenSSL random hexadecimal generator
VERSION="1.1.1"
RAW_URL="https://raw.githubusercontent.com/khahdihdz/hexmenu/main/hexmenu.sh"
set -u

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
BIN_DIR="$PREFIX/bin"
COMMAND="$BIN_DIR/hexmenu"

C=$'\033[0;36m'; G=$'\033[0;32m'; Y=$'\033[1;33m'; R=$'\033[0;31m'; W=$'\033[0m'

pause() { printf '\n'; read -r -p "Nhấn Enter để tiếp tục..." _; }

ensure_openssl() {
  if ! command -v openssl >/dev/null 2>&1; then
    echo -e "${Y}Chưa có OpenSSL. Đang cài đặt...${W}"
    pkg install -y openssl || return 1
  fi
}

install_menu() {
  mkdir -p "$BIN_DIR" || return 1
  local source="${BASH_SOURCE[0]}"
  if [[ -f "$source" && "$source" != "$COMMAND" ]]; then
    cp "$source" "$COMMAND" || return 1
  elif [[ "$source" == "$COMMAND" ]]; then
    echo -e "${Y}Lệnh hexmenu đã được cài đặt tại $COMMAND${W}"
    return 0
  else
    echo -e "${R}Không tìm thấy file script nguồn.${W}"
    return 1
  fi
  chmod 755 "$COMMAND"
  echo -e "${G}Cài đặt thành công. Gõ hexmenu để mở menu.${W}"
}

update_menu() {
  if [[ ! -f "$COMMAND" ]]; then
    echo -e "${Y}Chưa cài lệnh hexmenu. Hãy chọn mục 2 để cài trước.${W}"
    return 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo -e "${Y}Đang cài curl để cập nhật...${W}"
    pkg install -y curl || return 1
  fi

  local tmp remote_version
  tmp=$(mktemp) || return 1
  echo "Đang kiểm tra phiên bản mới..."
  if ! curl -fsSL "$RAW_URL" -o "$tmp"; then
    rm -f "$tmp"
    echo -e "${R}Không thể tải bản cập nhật. Kiểm tra kết nối mạng.${W}"
    return 1
  fi

  if ! bash -n "$tmp"; then
    rm -f "$tmp"
    echo -e "${R}Bản cập nhật không hợp lệ, đã hủy.${W}"
    return 1
  fi

  remote_version=$(grep -m1 '^VERSION=' "$tmp" | cut -d '"' -f2)
  if [[ -z "$remote_version" ]]; then
    rm -f "$tmp"
    echo -e "${R}Không đọc được phiên bản từ máy chủ.${W}"
    return 1
  fi

  if [[ "$remote_version" == "$VERSION" ]]; then
    rm -f "$tmp"
    echo -e "${G}Bạn đang sử dụng phiên bản mới nhất (v$VERSION).${W}"
    return 0
  fi

  chmod 755 "$tmp"
  if ! mv -f "$tmp" "$COMMAND"; then
    rm -f "$tmp"
    echo -e "${R}Không thể ghi bản cập nhật vào $COMMAND.${W}"
    return 1
  fi

  echo -e "${G}Đã cập nhật HEX MENU: v$VERSION → v$remote_version.${W}"
  echo "Đang khởi động lại menu..."
  exec "$COMMAND"
}

uninstall_menu() {
  if [[ -f "$COMMAND" ]]; then
    rm -f "$COMMAND"
    echo -e "${G}Đã gỡ lệnh hexmenu.${W}"
  else
    echo -e "${Y}Lệnh hexmenu chưa được cài đặt.${W}"
  fi
}

generate_hex() {
  clear
  echo -e "${C}========== TẠO MÃ HEX ==========${W}"
  echo "1. 16 ký tự (8 byte)"
  echo "2. 32 ký tự (16 byte)"
  echo "3. 64 ký tự (32 byte)"
  echo "4. 128 ký tự (64 byte)"
  echo "5. Tùy chỉnh (2–8192 ký tự, số chẵn)"
  echo "0. Quay lại"
  read -r -p "Chọn: " choice

  case "$choice" in
    1) length=16 ;; 2) length=32 ;; 3) length=64 ;; 4) length=128 ;;
    5)
      read -r -p "Nhập số ký tự HEX: " length
      if ! [[ "$length" =~ ^[0-9]+$ ]] || (( length < 2 || length > 8192 || length % 2 != 0 )); then
        echo -e "${R}Độ dài không hợp lệ. Cần là số chẵn từ 2 đến 8192.${W}"
        pause; return
      fi
      ;;
    0) return ;;
    *) echo -e "${R}Lựa chọn không hợp lệ.${W}"; pause; return ;;
  esac

  ensure_openssl || { pause; return; }
  read -r -p "Số lượng mã (1–100) [1]: " count
  count="${count:-1}"
  if ! [[ "$count" =~ ^[0-9]+$ ]] || (( count < 1 || count > 100 )); then
    echo -e "${R}Số lượng không hợp lệ.${W}"; pause; return
  fi

  echo
  local result="" first=""
  for ((i=1; i<=count; i++)); do
    result=$(openssl rand -hex "$((length / 2))") || {
      echo -e "${R}OpenSSL không tạo được mã.${W}"; pause; return;
    }
    [[ $i -eq 1 ]] && first="$result"
    printf '%s[%d]%s %s\n' "$C" "$i" "$W" "$result"
  done

  if (( count == 1 )) && command -v termux-clipboard-set >/dev/null 2>&1; then
    printf '%s' "$first" | termux-clipboard-set && echo -e "${G}Đã sao chép mã vào clipboard.${W}"
  elif (( count == 1 )); then
    echo -e "${Y}Cài Termux:API và chạy pkg install termux-api để bật sao chép nhanh.${W}"
  fi
  pause
}

if [[ "${1:-}" == "--install" ]]; then install_menu; exit $?; fi
if [[ "${1:-}" == "--uninstall" ]]; then uninstall_menu; exit $?; fi
if [[ "${1:-}" == "--update" ]]; then update_menu; exit $?; fi
if [[ "${1:-}" == "--help" ]]; then
  echo "HEX MENU: $0 [--install|--uninstall|--help]"
  exit 0
fi

while true; do
  clear
  echo -e "${C}"
  echo "╔══════════════════════════════╗"
  echo "║          HEX MENU            ║"
  echo "║     OpenSSL Random HEX       ║"
  echo "╚══════════════════════════════╝"
  echo -e "${W}"
  echo "1. Tạo mã HEX"
  echo "2. Cài lệnh mở menu nhanh"
  echo "3. Gỡ lệnh mở menu nhanh"
  echo "4. Kiểm tra / cài OpenSSL"
  echo "5. Kiểm tra / cập nhật phiên bản mới"
  echo "0. Thoát"
  echo "Phiên bản: v$VERSION"
  echo
  read -r -p "Lựa chọn: " option
  case "$option" in
    1) generate_hex ;;
    2) install_menu; pause ;;
    3) uninstall_menu; pause ;;
    4) ensure_openssl && openssl version; pause ;;
    5) update_menu; pause ;;
    0) exit 0 ;;
    *) echo -e "${R}Lựa chọn không hợp lệ.${W}"; sleep 1 ;;
  esac
done
