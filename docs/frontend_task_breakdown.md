# 🎨 Frontend - Detailed Task Breakdown

Tài liệu này lưu trữ các quyết định về phát triển Frontend dự án **Re**. Mỗi đầu việc được gán một ID và sẽ được chốt phương án thực hiện trước khi triển khai.

---

## 🛠️ Trạng thái các Task (Task Status)

- [x] `FE-001`: UI Component System (Shadcn/UI)
- [x] `FE-002`: Charts & Data Visualization (Chart.js)
- [x] `FE-003`: State Management & API Fetching (Zustand + TanStack Query)
- [x] `FE-004`: Layout & Responsive Design (Top-nav Bar)

---

## 🚀 Chi tiết phương án & Quyết định

### `FE-001`: UI Component System
**Quyết định:** **Shadcn/UI**.
- *Cơ chế:* Cài đặt trực tiếp từng thành phần (Button, Dialog, Input, v.v.) vào project. Sử dụng TailwindCSS để tùy chỉnh giao diện.
- *Ưu điểm:* Linh hoạt tối đa, code sạch, giao diện hiện đại.

---

### `FE-002`: Charts & Data Visualization
**Quyết định:** **Chart.js**.
- *Cơ chế:* Sử dụng Canvas để vẽ biểu đồ, đảm bảo hiệu năng cao khi hiển thị nhiều điểm dữ liệu metric.
- *Lưu ý:* Cần cài đặt `react-chartjs-2` để tích hợp mượt mà với React.

---

### `FE-003`: State Management & API Fetching
**Các lựa chọn đề xuất:**
1. **Zustand + TanStack Query (React Query):**
   - *Ưu điểm:* Quản lý server state (caching, loading) cực mạnh. Zustand cho global state rất nhẹ.
   - *Phù hợp:* Các ứng dụng cần query liên tục dữ liệu giám sát.
2. **Context API + SWR:**
   - *Ưu điểm:* Tích hợp sâu với Next.js, đơn giản hơn nếu không có quá nhiều state phức tạp.

---

### `FE-004`: Layout & Theme Implementation
- [ ] **Dashboard Layout:** Sidebar (Sidebar cố định bên trái) vs Top-nav.
- [ ] **Real-time Update:** Cơ chế WebSockets để hiển thị dữ liệu stream từ gRPC backend lên UI.
- [ ] **Dark Mode:** Tích hợp `next-themes` cho Dark/Light mode switcher.

---

*Ghi chú: Mỗi task sẽ được cập nhật phương án chốt tại đây sau khi người dùng đồng ý.*
