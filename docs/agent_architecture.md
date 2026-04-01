# Kiến trúc Agent & Nghiệp vụ thu thập dữ liệu (Docker SDK)

Tài liệu này mô tả chi tiết kiến trúc hoạt động của thành phần **Agent (Scraper)** trong hệ thống RE, sử dụng Docker SDK để thu thập thông số (metrics) và trạng thái (events) từ các máy chủ/container, sau đó đẩy về Backend xử lý.

---

## 1. Tổng quan Luồng kiến trúc (Data Pipeline)

Luồng đi của dữ liệu từ cấp độ phần cứng (Host) cho đến giao diện người dùng (UI) diễn ra như sau:

> **[Docker Daemon]** --(Unix/TCP Socket)--> **[Agent (Go)]** --(gRPC Stream)--> **[RE Backend]** --(Event Bus)--> **[WebSocket]** --> **[React UI]**

### Trách nhiệm các thành phần
- **Agent (The Scraper):** Là một tiến trình (daemon) chạy độc lập trên mỗi máy chủ cần giám sát. Sử dụng `Docker SDK` để tương tác với Docker Daemon nội bộ. Nhiệm vụ chính là lấy dữ liệu thô (JSON), tính toán ra các chỉ số (% CPU, MB RAM) và đóng gói thành Protobuf gửi đi.
- **Backend (Data Receiver):** Không gọi trực tiếp Docker SDK. Mở server gRPC để nhận dữ liệu từ các Agent trỏ về. Xử lý xác thực (Auth), lưu trữ vào Database (Timeseries) và Pub/Sub dữ liệu lên Websocket ngay lập tức.

---

## 2. Các API trọng tâm của Docker SDK

Agent sử dụng thư viện `github.com/docker/docker/client` để gọi trực tiếp xuống Docker API Engine. Các API cốt lõi được sử dụng bao gồm:

### a. `ContainerList` (Discovery & Sync)
- **Mục đích:** Lấy danh sách toàn bộ các container đang tồn tại trên Host và trạng thái hiện tại của chúng.
- **Nghiệp vụ:** 
  - Chạy định kỳ (Ví dụ: mỗi 1 phút). 
  - Báo cáo lên Backend trạng thái vòng đời của một container (Tạo mới, Đang chạy, Tạm dừng, Đã thoát).
  - Cung cấp Metadata (ID, Tên, Image, Ports) để Backend quản lý `Assets` UI.

### b. `ContainerStats` (Real-time Metrics)
- **Mục đích:** Thu thập thông số tiêu thụ tài nguyên phần cứng của từng Container tương tự như lệnh `docker stats`.
- **Nghiệp vụ:**
  - Với mỗi container đang `Running`, Agent tạo một tiểu trình (Goroutine) gọi API bằng chế độ `stream=true`.
  - Liên tục nhận luồng raw JSON chứa: Memory Stats, CPU utilization, Network I/O, Disk Block I/O.
  - **Aggregator (Gom nhóm dữ liệu):** Agent không gửi ngay lập tức lên Backend mỗi khi nhận 1 payload JSON. Thay vào đó, nó sẽ tính toán công thức (Ví dụ tính % CPU từ `cpu_stats` và `precpu_stats`) rồi lưu đệm bộ nhớ (Buffer) trong khoảng 5 giây.

### c. `Events` (Real-time Triggers & Alerting)
- **Mục đích:** Lắng nghe và phản ứng ngay lập tức với các sự kiện thay đổi hệ thống.
- **Nghiệp vụ:**
  - Theo dõi các event quan trọng như `start`, `stop`, `die`, `oom` (Out of memory).
  - Khác với `ContainerList` phải đợi đến chu kỳ quét, `Events` cung cấp tín hiệu tức thời.
  - Gửi gRPC khẩn cấp báo động cho hệ thống Backend nếu một dịch vụ quan trọng bị sập.

---

## 3. Luồng hoạt động chi tiết của Agent

Để hiện thực hoá các hệ thống trên, vòng đời của một Agent sẽ trải qua các bước:

1. **Khởi động & Xác thực:** 
   - Đọc cấu hình (Client ID, Secret, gRPC Endpoint).
   - Gọi gRPC lên Backend để `Register` và nhận Token xác thực.
2. **Ping & Khởi tạo luồng quét:** 
   - Dùng `ContainerList` cập nhật tình hình máy Host.
   - Quét ra tập hợp danh sách các `ContainerIDs` hợp lệ để theo dõi.
3. **Mở luồng Metrics & Event:** 
   - Khởi tạo Goroutines tương ứng cho `ContainerStats` (Tính toán số liệu) và `Events` (Chờ cảnh báo).
4. **Đóng gói & Phân phối:** 
   - Agent gom dữ liệu thành các gói Batch.
   - Đẩy liên tục qua **gRPC Bidirectional/Client Streaming** (`StreamMetrics`) lên Server bằng kết nối dai dẳng bền bỉ.
5. **Heartbeat (Nhịp tim):** 
   - Gọi định kỳ một hàm ping nhỏ để Backend biết máy chủ (Host) này vẫn đang sống (Tránh ngắt kết nối ảo).

---

## 4. Tích hợp với Giai đoạn 6 (Backend)

Phần công việc của Agent ở trên khớp hoàn toàn với Backend ở Giai đoạn 6 (`task.md`):

- **[6.1] Database Schema:** Backend cần bảng `metrics` cực tối ưu để nhận hàng ngàn request **batch insert** từ các Agent dội vào cùng một giây.
- **[6.2] gRPC Layer:** Nơi Backend định nghĩa `.proto` cho cấu trúc dữ liệu mà Agent sẽ gửi (Phải nhẹ và được định kiểu rõ ràng thay vì JSON động).
- **[6.3] WebSocket Hub:** Khi gRPC Service nhận xong một `MetricsBatch` từ Agent, nó kích hoạt Event Bus để đẩy ngay gói dữ liệu đó đi đến UI hiển thị biểu đồ mà không có độ trễ.
