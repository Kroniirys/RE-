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

## 📡 Giai đoạn 6: Business Logic & Real-time Monitoring
Trong giai đoạn này, hệ thống sẽ mở rộng để nhận cục bộ dữ liệu từ các Agent/Scraper, xử lý luồng sự kiện thời gian thực và đẩy lên UI.

### 6.1. Data Access & Schema (Metrics & Assets)
- [x] `BE-FS6-01`: Thiết kế schema DB (PostgreSQL) chuyên dụng cho cấu trúc Timeseries và viết file migration:
    - Bảng thông tin định danh: `assets` (ID, Hostname, IP, Status v.v.) và `containers` bảng phụ lưu vết tiến trình Docker của một asset.
    - Bảng lưu trữ Metrics chia rẽ theo từng loại dữ liệu (`cpu`, `ram`, `disk`, `network`, `docker`), kết hợp kiến trúc **Data Rollup**:
        - Bảng **Raw** (Dữ liệu tức thời/giây): Chỉ lưu trữ trong **1 ngày** gần nhất.
        - Bảng **Chu kỳ ngắn** (1min, 5min, 10min, 1hour): Lưu giữ trong vòng **3 tháng**.
        - Bảng **Dài hạn** (1day): Trích xuất báo cáo lưu trữ lâu dài tới **1 năm**.
        - mỗi metrics trong các bảng chu kỳ sẽ chia ra thành các cột avg, min, max, wavg. 
- [x] `BE-FS6-02`: Phát triển nghiệp vụ Data Access Layer cho tập Metrics bằng Golang & `sqlc`:
    - Viết các câu lệnh CRUD, đặc biệt tối ưu hoá **Batch Insert** để tiếp nhận số lượng bản ghi khổng lồ.
    - Xây dựng **Background Worker (Go Cronjobs/Goroutines)** chuyên trách:
        - Tự động lấy dữ liệu bảng Raw, tính toán (Min/Max/Avg) và đổ vào các bảng chu kỳ tương ứng theo thời gian thực.
        - Thực thi logic tự động dọn dẹp (**Soft Delete/Hard Delete**) các bản ghi hết hạn (như xoá Raw quá 1 ngày).
*(Ghi chú: Luồng chi tiết về việc lấy tải (payload) và kỹ thuật đẩy dữ liệu từ Agent vào Database sẽ được phân tích rõ ở Task Thiết kế Agent).*

### 6.2. gRPC Agent Communication Layer
- [x] `BE-FS6-03`: Định nghĩa Protobuf (`.proto`) contracts cho giao tiếp giữa Agent và Backend: `Register`, `Heartbeat`, và `StreamMetrics`.
- [x] `BE-FS6-04`: Cấu hình và khởi chạy Server gRPC đồng thời cùng với HTTP REST API hiện tại.
- [x] `BE-FS6-05`: Xây dựng **gRPC Interceptors** để xác thực Agent (sử dụng Token/API Key hoặc mTLS) trước khi xử lý dữ liệu.
- [x] `BE-FS6-06`: Triển khai các dịch vụ (`Services`) gRPC để xử lý payload từ Agent, lưu vào CSDL và trigger Event Bus.
- [x] Xây dựng module **Scraper (Agent)** thực tế: Sử dụng Golang Docker SDK để kết nối daemon cục bộ, trích xuất Metrics, và bắn gRPC `StreamMetrics` thử nghiệm về Backend.
### 6.3. WebSocket Hub (Real-time UI Update)
- [ ] `BE-FS6-07`: Xây dựng **Internal Event Bus (PubSub)** cơ bản bằng Channel để chia sẻ dữ liệu giữa gRPC layer và HTTP layer.
- [ ] `BE-FS6-08`: Khởi tạo kiến trúc `WebSocket Hub` để quản lý các client models đang kết nối đến hệ thống (Rooms/Channels).
- [ ] `BE-FS6-09`: Phát triển API Endpoint nâng cấp (Upgrade) HTTP connection lên WebSocket, có bao gồm **xác thực JWT** của người dùng hiện hành.
- [ ] `BE-FS6-10`: Lắng nghe Event Bus: Khi có log/metrics mới đẩy vào từ Agent, broadcast message tương ứng thông qua WebSocket xuống các client đang theo dõi `Asset`.

### 6.4. Advanced Business Logic (REST APIs)
- [ ] `BE-FS6-11`: Phát triển nhóm REST APIs quản trị Server/Agent (List, Detail, Update Trạng Thái).
- [ ] `BE-FS6-12`: Cung cấp API truy vấn lịch sử `Metrics` (Có kết hợp Pagination hoặc Time-Range filtering).
- [ ] `BE-FS6-13`: Khảo sát và triển khai **Bidirectional Streaming** (gRPC) phục vụ Remote Execution (VD: Lệnh khởi động lại Container/Server từ UI xuống Agent).
