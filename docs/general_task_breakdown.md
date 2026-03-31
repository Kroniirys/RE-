# 📋 General Setup - Detailed Task Breakdown

Tài liệu này lưu trữ các quyết định về hạ tầng và khởi tạo dự án **Re**. Mỗi đầu việc được gán một ID và sẽ được chốt phương án thực hiện trước khi triển khai.

---

## 🛠️ Trạng thái các Task (Task Status)

- [x] `GEN-001`: Tech Stack Selection (Backend: Go/Gin, Frontend: Next.js)
- [x] `GEN-002`: Directory Structure Design (Standard: core/backend, core/frontend)
- [x] `GEN-003`: Boilerplate Initialization & Git Structure (Hybrid: cmd/, internal/ + Layered modules)
- [x] `GEN-004`: Docker & Containerization Environment (Mono-Compose)
- [x] `GEN-005`: Coding Standards, Linting & Git Hooks (Strict + Husky)
- [x] `GEN-006`: CI/CD Pipeline Configuration

---

## 🚀 Chi tiết phương án & Quyết định

### `GEN-001`: Tech Stack Selection
**Quyết định:** **Lựa chọn 1** — Backend: **Go (Gin)** | Frontend: **Next.js (TypeScript)**.
- *Lý do:* Hiệu năng cao, phù hợp với các hệ thống scraper/receiver và UI hiện đại.

---

### `GEN-002`: Directory Structure Design
**Quyết định:** **Lựa chọn 1** — **Standard Folders**.
- *Cấu trúc:* Phân tách rõ ràng thành `core/backend` và `core/frontend`.

---

### `GEN-003`: Boilerplate Initialization
**Quyết định:** **Hybrid Layered Structure**.
- *Cấu trúc:* Sử dụng `cmd/` cho entry point, `internal/` chứa các module.
- *Phân lớp:* Mỗi module trong `internal/` sẽ được chia thành `api/`, `service/`, `repository/`, `model/`.
- *Frontend:* Next.js project đặt tại `core/frontend`.

---

### `GEN-004`: Docker & Containerization
**Quyết định:** **Lựa chọn 1** — **Mono-Compose**.
- *Cấu trúc:* Một file `docker-compose.yml` tại root để quản lý Backend, Frontend và Database.

---

### `GEN-005`: Coding Standards & Linting
**Quyết định:** **Lựa chọn 2** — **Strict Standards + Git Hooks**.
- *Công cụ:* `golangci-lint` (Go), `eslint/prettier` (JS).
- *Automation:* Sử dụng `Husky` và `lint-staged` để tự động kiểm tra code khi commit.

---

### `GEN-006`: CI/CD Pipeline Configuration
**Quyết định:** **Lựa chọn 1** — GitHub Actions
