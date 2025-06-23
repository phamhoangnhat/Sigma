
# Sigma – Bộ gõ tiếng Việt thông minh

**Sigma** là phần mềm gõ tiếng Việt hiện đại dành cho Windows, hỗ trợ cấu hình riêng cho từng ứng dụng và tích hợp AI để tăng hiệu quả gõ.

---

## Hướng dẫn sử dụng và cài đặt

Xem hướng dẫn chi tiết cách sử dụng và cài đặt phần mềm tại liên kết sau:  
**[Tài liệu hướng dẫn sử dụng (HTML)](https://htmlpreview.github.io/?https://github.com/phamhoangnhat/Sigma/blob/main/Sigma%20User%20Guide.html)**

---

## Phụ thuộc

Sigma cần thư viện động `SigmaLib.dll` từ repository sau:  
**[SigmaLib – Thư viện xử lý tiếng Việt](https://github.com/phamhoangnhat/SigmaLib)**

Nếu bạn muốn build lại phần mềm từ mã nguồn, hãy build `SigmaLib.dll` trước và đặt nó cùng thư mục với `Sigma.exe`.

---

## Build từ mã nguồn

### Yêu cầu

- Qt 6.9.0  
- Visual Studio 2022 hoặc mới hơn  
- Đặt sẵn `SigmaLib.dll` trong cùng thư mục build với `Sigma.exe`

### Các bước thực hiện

```bash
git clone https://github.com/phamhoangnhat/Sigma.git
