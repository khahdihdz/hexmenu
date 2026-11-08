# HEX MENU – Termux

Menu tạo mã HEX ngẫu nhiên bằng **OpenSSL** dành cho Termux.

## Tính năng

- Tạo mã HEX 16, 32, 64 hoặc 128 ký tự.
- Tùy chỉnh độ dài từ 2 đến 8192 ký tự (bắt buộc số chẵn).
- Tạo tối đa 100 mã trong một lần.
- Tự kiểm tra và cài OpenSSL khi cần.
- Sao chép mã đơn vào clipboard nếu đã cài Termux:API.
- Cài đặt/gỡ lệnh mở nhanh `hexmenu`.

## Cài đặt nhanh

Mở Termux và chạy:

```bash
pkg update
pkg install -y curl openssl
curl -fsSL https://raw.githubusercontent.com/khahdihdz/hexmenu/main/install.sh | bash
```

Sau khi cài, mở menu bằng:

```bash
hexmenu
```

## Cập nhật

Chọn **5. Kiểm tra / cập nhật phiên bản mới** trong menu, hoặc chạy trực tiếp:

```bash
hexmenu --update
```

Script tải bản mới nhất từ nhánh `main`, kiểm tra cú pháp Bash trước khi thay thế. Nếu đã ở phiên bản mới nhất, script sẽ thông báo và không ghi đè file.

## Chạy không cần cài lệnh nhanh

```bash
curl -fsSL https://raw.githubusercontent.com/khahdihdz/hexmenu/main/hexmenu.sh -o hexmenu.sh
chmod +x hexmenu.sh
./hexmenu.sh
```

## Gỡ cài đặt

Trong menu chọn **3. Gỡ lệnh mở menu nhanh**, hoặc chạy:

```bash
hexmenu --uninstall
```

Lệnh gỡ chỉ xóa lệnh `hexmenu`, không gỡ OpenSSL.

## Clipboard (tùy chọn)

Cài ứng dụng Termux:API tương thích và chạy:

```bash
pkg install -y termux-api
```

## Định dạng

Mã HEX có số ký tự chẵn. Ví dụ 32 ký tự = 16 byte = 128 bit. Mã được tạo bởi `openssl rand -hex`, phù hợp để tạo giá trị ngẫu nhiên cho mục đích bảo mật.
