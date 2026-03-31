# ⚙️ Backend - Development Task List (Foundation)

Dưới đây là danh sách các task chi tiết cho 5 giai đoạn phát triển nền tảng ban đầu của dự án **Re**.

---

## 🏗️ Giai đoạn 1: CLI & Configuration (Cobra & Viper) [x]
- [x] `BE-FS1-01`: Khởi tạo Cobra Root Command và lệnh `serve` để chạy server.
- [x] `BE-FS1-02`: Tích hợp Viper để hỗ trợ đọc cấu hình từ file `config.toml`.
- [x] `BE-FS1-03`: Định nghĩa các cấu trúc dữ liệu mapping cấu hình (Database, Server, Auth).

---

## 🪵 Giai đoạn 2: Logging Architecture (Uber-Zap) [x]
- [x] `BE-FS2-01`: Triển khai Logger wrapper tại `backend/pkg/logger` sử dụng **Uber-Zap**.
- [x] `BE-FS2-02`: Khởi tạo folder `backend/log` chứa các file log (.gitkeep).
- [x] `BE-FS2-03`: Cấu hình Logger hỗ trợ ghi đồng thời ra Stdout (console) và các file log:
    - `server.log`: Các log hệ thống chung.
    - `api.log`: Các log về HTTP requests/responses.
    - `backup.log`: Các log về quá trình xử lý dữ liệu/backup.

---

## 🗄️ Giai đoạn 3: Data Access Layer (sqlc & Migrations) [x]
- [x] `BE-FS3-01`: Cấu hình `sqlc.yaml` với output tại `backend/pkg/db`.
- [x] `BE-FS3-02`: Thiết lập `golang-migrate` cho quản lý schema.
- [x] `BE-FS3-03`: Viết migration khởi tạo bảng `users` (BIGSERIAL).
- [x] `BE-FS3-04`: Implement DB Connection Pool với `pgxpool`.
- [x] `BE-FS3-05`: Tác hợp lệnh `migrate` vào Cobra CLI.

---

## 🚀 Giai đoạn 4: Core API (Identity & Monitoring Architecture) [/]
- [/] `BE-FS4-01`: Thiết lập cấu trúc `internal/app` để quản lý server tập trung.
- [/] `BE-FS4-02`: Đăng ký Connection Pool (DB) vào Server context thông qua Dependency Injection.
- [/] `BE-FS4-03`: Tích hợp các Middlewares nền tảng: Recovery, CORS, RequestID.
- [/] `BE-FS4-04`: Triển khai cơ chế **Graceful Shutdown** cho API và DB pool.
- [ ] `BE-FS4-05`: Endpoint `/health` phục vụ kiểm tra trạng thái dịch vụ (Up/Down).

---

## 🔐 Giai đoạn 5: Identity & Security (JWT & Bcrypt) [x]
- [x] `BE-FS5-01`: Triển khai hashing mật khẩu sử dụng thư viện **Bcrypt**.
- [x] `BE-FS5-02`: Xây dựng logic tạo và xác thực **JWT Token** (Access & Refresh Token).
- [x] `BE-FS5-03`: Phát triển **Auth Middleware** bảo vệ các endpoints cần định danh.
- [x] `BE-FS5-04`: Hoàn thiện các API: Đăng ký, Đăng nhập, Refresh Token và phân quyền Role-Based Access Control (RBAC) cơ bản.

---

## 🚀 Các Giai đoạn tiếp theo (Tóm tắt)
### Giai đoạn 6: Business Logic & Real-time Monitoring
- Phân rã task cho gRPC Service (Scraper/Agent communication).
- Triển khai **WebSocket Hub** để đẩy dữ liệu monitoring từ DB lên UI.
- Quản lý Logic nghiệp vụ nâng cao (Asset Management, Remote Execution).
