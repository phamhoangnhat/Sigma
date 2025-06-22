# Sigma – Bộ gõ tiếng Việt thông minh

**Sigma** là phần mềm gõ tiếng Việt hiện đại dành cho Windows, cấu hình theo ứng dụng, và tích hợp AI.

## 📘 Hướng dẫn sử dụng chi tiết và cài đặt
👉 [Xem tài liệu hướng dẫn sử dụng và link cài đặt phần mềm (HTML)](https://htmlpreview.github.io/?https://github.com/phamhoangnhat/Sigma/blob/main/Sigma%20User%20Guide.html)

## 🧩 Phụ thuộc
Sigma sử dụng thư viện động `SigmaLib.dll` từ repository:
🔗 [SigmaLib – thư viện xử lý tiếng Việt](https://github.com/phamhoangnhat/SigmaLib)
Nếu bạn muốn build lại từ mã nguồn, hãy build `SigmaLib.dll` trước và đặt cùng thư mục với `Sigma.exe`.

## 🔧 Build từ mã nguồn

### Yêu cầu:

- Qt 6.9.0
- Visual Studio 2022+
- Windows 10+ (64-bit)
- `SigmaLib.dll` (đặt sẵn cùng thư mục)

### Các bước:

```bash
git clone https://github.com/phamhoangnhat/Sigma.git
