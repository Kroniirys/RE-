# ⚙️ Backend - Detailed Task Breakdown

Tài liệu này lưu trữ các quyết định về phát triển Backend dự án **Re**. Mỗi đầu việc được gán một ID và sẽ được chốt phương án thực hiện trước khi triển khai.

---

## 🛠️ Trạng thái các Task (Task Status)

- [x] `BE-001`: Database Interaction & Schema (sqlc + golang-migrate)
- [x] `BE-002`: Core API & Middleware (Zap + URL Versioning)
- [x] `BE-003`: Auth System (JWT + Internal DB)
- [x] `BE-004`: Third-party Integrations (gRPC Stream)

---

## 🚀 Chi tiết phương án & Quyết định

### `BE-001`: Database Interaction & Schema
**Quyết định:** **sqlc** & **golang-migrate**.
- *Luồng:* Viết `.sql`, generate code Go bằng `sqlc`. Quản lý phiên bản bảng bằng `golang-migrate`.
- *Ưu điểm:* Tuyệt đối an toàn về kiểu dữ liệu (Type-safe), hiệu năng tối đa.

---

### `BE-002`: Core API & Middleware
**Quyết định:** **Uber-Zap** & **URL Versioning (`/api/v1`)**.
- *Logging:* Sử dụng Zap để có log có cấu trúc (Structure Log) và hiệu năng cao.
- *Versioning:* Dễ dàng nâng cấp API mà không làm gãy các client cũ.

---

### `BE-003`: Auth System
**Quyết định:** **JWT (JSON Web Token)**.
- *Cơ chế:* Cấp phát JWT sau khi đăng nhập thành công. Token được lưu trữ tại client (httponly cookie hoặc local storage).
- *Identity:* Sử dụng **Internal Database** (Username/Password hashing với bcrypt).
- *Authorization:* Triển khai **RBAC** đơn giản (Admin/Viewer).

---

### `BE-004`: Third-party Integrations
**Quyết định:** **gRPC Stream (Push Model)**.
- *Cơ chế:* Các Agent/Scrapers sẽ mở kết nối gRPC bền vững và đẩy dữ liệu (Streaming) về Backend.
- *Ưu điểm:* Hiệu năng cực cao, latency thấp, phù hợp cho hệ thống real-time monitoring quy mô lớn.

---

*Ghi chú: Mỗi task sẽ được cập nhật phương án chốt tại đây sau khi người dùng đồng ý.*
