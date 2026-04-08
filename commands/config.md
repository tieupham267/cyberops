# /secops:config — Xem và quản lý cấu hình secops

Bạn đang quản lý cấu hình plugin secops. Config được lưu tại `~/.claude/secops.yaml`.

## Xử lý theo arguments

### Không có argument → Hiển thị config hiện tại

Đọc `~/.claude/secops.yaml`. Hiển thị:

```text
## SecOps Config

File: ~/.claude/secops.yaml

| Setting       | Value                        |
|---------------|------------------------------|
| context_dir   | C:\SecOps-Data\context       |
| workflows_dir | C:\SecOps-Data\workflows     |

Dùng /secops:config <key> <value> để thay đổi.
Dùng /secops:config reset để xóa config và quay về working directory.
```

Nếu file không tồn tại:

```text
## SecOps Config

Chưa có config file (~/.claude/secops.yaml).
Đang dùng working directory mặc định:
  context_dir:   ./context
  workflows_dir: ./workflows

Dùng /secops:config context_dir <path> để chỉ định folder riêng.
Hoặc chạy /secops:setup-profile để setup tự động.
```

### `context_dir <path>` → Đổi context directory

1. Kiểm tra `<path>` là absolute path hợp lệ
2. Nếu folder chưa tồn tại → hỏi: "Folder chưa tồn tại. Tạo mới? [Y/n]"
   - Nếu Y → tạo folder + subfolders (`org-docs/`, `process-docs/`)
3. Đọc `~/.claude/secops.yaml` hiện tại (hoặc tạo mới nếu chưa có)
4. Cập nhật `context_dir: <path>`
5. Ghi lại file
6. Hiển thị: `✓ context_dir đã cập nhật: <path>`

### `workflows_dir <path>` → Đổi workflows directory

1. Kiểm tra `<path>` là absolute path hợp lệ
2. Nếu folder chưa tồn tại → hỏi: "Folder chưa tồn tại. Tạo mới? [Y/n]"
   - Nếu Y → tạo folder + subfolders (`defaults/`, `soc/`, `ir/`, `grc/`, `devsecops/`, `advisory/`, `awareness/`)
3. Nếu `<path>/defaults/` trống → hỏi: "Copy default workflows từ plugin? [Y/n]"
   - Nếu Y → copy từ plugin dir
4. Đọc `~/.claude/secops.yaml` hiện tại (hoặc tạo mới nếu chưa có)
5. Cập nhật `workflows_dir: <path>`
6. Ghi lại file
7. Hiển thị: `✓ workflows_dir đã cập nhật: <path>`

### `reset` → Xóa config, quay về working directory

1. Hỏi xác nhận: "Xóa ~/.claude/secops.yaml? Plugin sẽ dùng working directory mặc định. [Y/n]"
2. Nếu Y → xóa file `~/.claude/secops.yaml`
3. Hiển thị: `✓ Config đã xóa. Sử dụng working directory mặc định.`

**Lưu ý**: Lệnh `reset` chỉ xóa config file, KHÔNG xóa data trong context/workflows folders.

### `show-paths` → Hiển thị resolved paths đang dùng

Hiển thị paths thực tế mà agents đang sử dụng (sau khi resolve):

```text
## Resolved Paths

Config file: ~/.claude/secops.yaml (found / not found)

context_dir:   C:\SecOps-Data\context    ← from secops.yaml
workflows_dir: C:\SecOps-Data\workflows  ← from secops.yaml

Files found:
  ✓ company-profile.yaml
  ✓ workflows/defaults/ (10 files)
  ✗ context/org-docs/ (empty)
```

## Validation

Khi cập nhật bất kỳ path nào:

- Path phải là **absolute path** (không dùng relative path như `./context`)
- Trên Windows: chấp nhận cả `C:\path` và `/c/path`
- Kiểm tra path không trỏ vào plugin directory (`~/.claude/plugins/cache/...`)
- Nếu path trỏ vào plugin dir → cảnh báo và từ chối:
  ```text
  ✗ Không nên dùng plugin directory làm data path.
    Chọn folder khác ngoài ~/.claude/plugins/
  ```
