# 🕵️‍♂️ Database Collector - Progress Tracking

Bản này theo dõi tiến độ chi tiết của việc phát triển DB Collector từ xa.

---

## 🏗️ Giai đoạn 1: Data Modeling & Schema
- [x] `DB-FIX-01`: Cập nhật `agent.proto` để hỗ trợ payload Database.
- [x] `DB-FIX-02`: Chạy lệnh `buf generate` để cập nhật Go code từ proto.
- [x] `DB-FIX-03`: Định nghĩa cấu trúc `RemoteDBConfig` trong file cấu hình của Agent.

## 📡 Giai đoạn 2: Collector Implementation (PostgreSQL)
- [x] `DB-COL-01`: Cài đặt driver database cần thiết (`pgx`).
- [x] `DB-COL-02`: Viết `PostgresCollector` để trích xuất metrics (Sessions, TPS, Size).
- [ ] `DB-COL-03`: Implement cơ chế retry và timeout cho kết nối DB từ xa.
- [ ] `DB-COL-04`: Unit test cho phần Collector xử lý SQL kết quả.

## 🚀 Giai đoạn 3: Integration & Testing
- [x] `DB-INT-01`: Tích hợp Collector mới vào vòng lặp `StreamMetrics` của Scraper Client.
- [ ] `DB-INT-02`: Đảm bảo Backend có thể nhận và log được dữ liệu mới.
- [ ] `DB-INT-03`: Chạy thử nghiệm thực tế với Docker PostgreSQL từ xa.

---

## 📊 Trạng thái hiện tại:
- [x] Đã hoàn thành phần khung (Framework) và Collector cho Postgres.
- [ ] Kế tiếp: Chạy thử nghiệm và xử lý Log tại Backend.
