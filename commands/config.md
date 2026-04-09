# /cyberops:config — Xem và quản lý cấu hình cyberops

Bạn đang quản lý cấu hình plugin cyberops. Config được lưu tại `~/.claude/cyberops.yaml`.

## Xử lý theo arguments

### Không có argument → Hiển thị config hiện tại

Đọc `~/.claude/cyberops.yaml`. Hiển thị:

```text
## CyberOps Config

File: ~/.claude/cyberops.yaml

### Sources (document folders)
  1. D:\Company-Docs          (scanned: 2026-04-09, 35 files)
  2. \\server\shared\security  (scanned: 2026-04-01, 12 files)

### Mapping
  org_docs:     8 files
  process_docs: 12 files
  regulations:  5 files
  standards:    3 files
  policies:     6 files
  reports:      8 files
  templates:    5 files

### Output
  profile:   ./context/company-profile.yaml
  workflows: ./workflows

Dùng /cyberops:config <subcommand> để quản lý.
```

Nếu file không tồn tại:

```text
## CyberOps Config

Chưa có config. Chạy /cyberops:setup-profile để scan tài liệu và tạo config.
```

### `add-source <path>` → Thêm document source

1. Kiểm tra `<path>` là path hợp lệ và tồn tại
2. Đọc `~/.claude/cyberops.yaml` (hoặc tạo mới)
3. Thêm vào `sources` list
4. Tự động scan + phân loại files trong source mới
5. Hiển thị kết quả scan → xin confirm mapping
6. Merge vào mapping hiện tại
7. Hiển thị: `✓ Source added: <path> (N files mapped)`

### `remove-source <path>` → Xóa document source

1. Xóa source khỏi `sources` list
2. Xóa tất cả files từ source đó khỏi `mapping`
3. Hiển thị: `✓ Source removed: <path> (N files removed from mapping)`

### `list-sources` → Liệt kê tất cả sources

```text
## Document Sources

| # | Path | Last Scanned | Files |
|---|------|-------------|-------|
| 1 | D:\Company-Docs | 2026-04-09 | 35 |
| 2 | \\server\shared\security | 2026-04-01 | 12 |
```

### `rescan` → Rescan tất cả sources

1. Scan lại tất cả paths trong `sources`
2. Phát hiện files mới, files đã xóa, files đã thay đổi
3. Hiển thị diff:

   ```text
   ## Rescan Results

   + 3 files mới (cần phân loại)
   ~ 2 files đã thay đổi
   - 1 file đã xóa (removed from mapping)

   New files:
     D:\Company-Docs\ISMS\new-policy.docx → [policies?]
     D:\Company-Docs\Reports\q1-2026.pdf → [reports?]
     D:\Company-Docs\IT\k8s-setup.md → [org_docs?]

   Confirm? [Yes / Edit]
   ```

### `show-mapping` → Hiển thị full mapping

Liệt kê tất cả files theo category:

```text
## Document Mapping

### org_docs (8 files)
  1. D:\Company-Docs\IT\org-chart.xlsx
  2. D:\Company-Docs\IT\tech-stack.md
  ...

### process_docs (12 files)
  1. D:\Company-Docs\QuyTrinh\incident-response-sop.docx
  ...

### regulations (5 files)
  ...
```

### `move <file> <category>` → Di chuyển file sang category khác

1. Tìm `<file>` trong mapping (match partial path)
2. Xóa khỏi category hiện tại
3. Thêm vào `<category>` mới
4. Hiển thị: `✓ Moved: incident-response.docx → process_docs (was: org_docs)`

### `output profile <path>` → Đổi output path cho profile

```text
✓ Profile output: <path>
```

### `output workflows <path>` → Đổi output path cho workflows

```text
✓ Workflows output: <path>
```

### `reset` → Xóa config

1. Hỏi xác nhận: "Xóa ~/.claude/cyberops.yaml? [Y/n]"
2. Nếu Y → xóa file
3. Hiển thị: `✓ Config đã xóa.`

**Lưu ý**: Chỉ xóa config file. KHÔNG xóa tài liệu gốc hay generated files.

## Validation

- Source paths phải tồn tại và readable
- Không cho thêm plugin directory (`~/.claude/plugins/cache/...`) làm source
- Category hợp lệ: `org_docs`, `process_docs`, `regulations`, `standards`, `policies`, `reports`, `templates`
