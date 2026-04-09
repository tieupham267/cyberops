# /secops:setup-profile — Scan tài liệu tổ chức và build company profile

Bạn đang thực hiện scan, phân loại tài liệu, và tạo/cập nhật company profile.

Plugin là **scan-based** — đọc tài liệu tại chỗ từ source folders của user, phân loại vào mapping trong `secops.yaml`. KHÔNG yêu cầu user copy files vào bất kỳ folder nào.

## Quy trình

### Step 0: Đọc config và profile — BẮT BUỘC trước khi làm bất cứ gì

**Hành động bắt buộc theo thứ tự:**

1. Đọc file `~/.claude/secops.yaml` bằng Read tool
2. Kiểm tra file có key `sources:` không (không phải `output:` — đó là output paths)
3. Kiểm tra file có key `mapping:` không
4. Đọc file company-profile.yaml (path từ `output.profile` trong secops.yaml)
5. Đếm bao nhiêu fields đã có giá trị, bao nhiêu fields trống/rỗng

**Sau khi đọc xong, branch theo điều kiện:**

---

**Case A: Có `sources:` VÀ `mapping:`** → hiển thị và hỏi:

```text
Trạng thái hiện tại (từ secops.yaml):
  Sources: D:\Company-Docs (scanned: 2026-03-15)
  Mapping: 12 org_docs, 8 process_docs, 5 regulations, 3 policies
  Profile: 15/20 fields đã điền, 5 fields trống

Bạn muốn:
1. Rescan sources (cập nhật mapping)
2. Thêm source mới
3. Build/update profile từ mapping hiện tại
4. Điền tiếp fields trống qua Q&A
5. Setup mới từ đầu
```

**DỪNG LẠI VÀ CHỜ USER CHỌN** trước khi tiếp tục.

---

**Case B: Có config nhưng KHÔNG có `sources:`/`mapping:`** → hiển thị và hỏi:

```text
Trạng thái hiện tại (từ secops.yaml):
  Output paths: Đã cấu hình ✓
  Sources: Chưa trỏ tới folder tài liệu nào
  Profile: 22/37 fields đã điền, 15 fields còn trống

Fields còn trống:
  org_mapping: department names, leads
  escalation: severity contacts, SLAs
  security: scanner, vulnerability_mgmt
  ...

Bạn muốn:
1. Trỏ tới folder(s) tài liệu để scan và extract thêm
2. Điền tiếp fields trống qua Q&A
3. Xem profile hiện tại
```

**DỪNG LẠI VÀ CHỜ USER CHỌN** trước khi tiếp tục.

→ Option 1: chuyển sang Step 2
→ Option 2: chuyển sang Step 9 (Q&A chỉ hỏi fields trống)
→ Option 3: hiển thị profile rồi hỏi lại

---

**Case C: Chưa có `~/.claude/secops.yaml`** → chuyển sang Step 1.

---

**QUAN TRỌNG:**

- Trạng thái dựa trên secops.yaml + profile, KHÔNG check nội dung folder.
- KHÔNG tự chạy tiếp mà không hỏi user chọn option.
- Mọi thay đổi profile đều hiển thị **diff** trước khi apply (Step 7).

### Step 1: Hỏi output paths (chỉ lần đầu)

Chỉ chạy khi chưa có config. Nếu đã có → skip sang Step 2.

```text
Plugin cần 3 thư mục để lưu dữ liệu. Tài liệu gốc của bạn KHÔNG bị di chuyển.

Output paths (Enter để dùng mặc định):
  Context  [./context]:
  Workflows [./workflows]:
  References [./references]:
```

Tạo cấu trúc thư mục + default workflow templates.

### Step 2: Thu thập document sources

Hỏi user **ngay sau Step 1** (không dừng lại):

```text
Trỏ tôi tới folder(s) chứa tài liệu tổ chức hiện có.
Plugin sẽ scan tại chỗ — KHÔNG copy/di chuyển files.

Ví dụ:
  D:\Company-Docs
  \\fileserver\IT-Department
  C:\Users\you\OneDrive\Work

Nếu chưa có tài liệu, gõ "skip" — tôi sẽ hỏi Q&A để điền profile.

Paths:
```

Chấp nhận:

- Absolute paths (Windows: `C:\...`, `D:\...`; Linux/Mac: `/home/...`)
- Network paths (`\\server\share`)
- Cloud sync paths (OneDrive, Google Drive, Dropbox)
- Nhiều paths (mỗi dòng một path)
- `skip` → chuyển sang **Step 8: Q&A fallback**

### Step 3: Scan và phân loại tài liệu

Với mỗi source path:

1. **Scan cấu trúc folder** — Glob tất cả files (`.md`, `.txt`, `.docx`, `.pdf`, `.xlsx`, `.csv`, `.yaml`, `.json`, `.png`, `.jpg`)
2. **Đọc folder names + file names** — dùng tên folder/file để phân loại sơ bộ
3. **Đọc nội dung** từng file (summary/first page cho files lớn)
4. **Phân loại** mỗi file vào categories:

| Category | Dấu hiệu nhận biết | Ví dụ |
| --- | --- | --- |
| `org_docs` | Sơ đồ tổ chức, danh sách team, tech stack, asset inventory, org chart | org-chart.xlsx, he-thong.md |
| `process_docs` | SOP, playbook, runbook, quy trình, workflow, hướng dẫn xử lý | incident-response-sop.docx |
| `regulations` | Luật, nghị định, thông tư, circular, decree, law | luat-anm-2018.pdf |
| `standards` | ISO, NIST, PCI, CIS, framework controls | iso27001-controls.xlsx |
| `policies` | ISMS policy, chính sách nội bộ, acceptable use, access control | access-control-policy.docx |
| `reports` | Báo cáo đánh giá, audit report, pentest report, risk assessment | audit-2025-q4.pdf |
| `templates` | Template, mẫu biểu, form | incident-report-template.docx |
| `other` | Không phân loại được rõ ràng | (hỏi user) |

### Step 4: Hiển thị kết quả scan và xin confirm

```text
## Scan Results

Sources: 2 folders, 47 files found

### org_docs (8 files)
  D:\Company-Docs\IT\org-chart.xlsx
  D:\Company-Docs\IT\he-thong\tech-stack.md
  D:\Company-Docs\IT\he-thong\network-diagram.png
  D:\Company-Docs\HR\team-security.csv
  ...

### process_docs (12 files)
  D:\Company-Docs\QuyTrinh\incident-response-sop.docx
  D:\Company-Docs\QuyTrinh\change-management.pdf
  D:\Company-Docs\IT\SOPs\access-review.md
  ...

### regulations (5 files)
  D:\Company-Docs\PhapLy\luat-anm-2018.pdf
  D:\Company-Docs\PhapLy\nd-13-2023.pdf
  ...

### policies (6 files)
  D:\Company-Docs\ISMS\access-control-policy.docx
  D:\Company-Docs\ISMS\data-classification-policy.docx
  ...

### standards (3 files)
  D:\Company-Docs\Compliance\ISO27001\controls.xlsx
  ...

### reports (8 files)
  ...

### other (5 files — cần xác nhận)
  D:\Company-Docs\Misc\meeting-notes-2025.md → [org_docs / process_docs / skip?]
  ...

Confirm mapping? [Yes / Edit / Rescan]
```

**Edit mode**: User có thể:

- Di chuyển file giữa categories
- Đánh dấu `skip` cho files không liên quan
- Thêm files thủ công

### Step 5: Lưu mapping vào config

Lưu vào `~/.claude/secops.yaml`:

```yaml
# ~/.claude/secops.yaml
# Auto-generated by /secops:setup-profile

sources:
  - path: "D:\\Company-Docs"
    scanned_at: "2026-04-09T10:30:00"
  - path: "\\\\server\\shared\\security"
    scanned_at: "2026-04-09T10:30:00"

mapping:
  org_docs:
    - "D:\\Company-Docs\\IT\\org-chart.xlsx"
    - "D:\\Company-Docs\\IT\\he-thong\\tech-stack.md"
    - "D:\\Company-Docs\\HR\\team-security.csv"
  process_docs:
    - "D:\\Company-Docs\\QuyTrinh\\incident-response-sop.docx"
    - "D:\\Company-Docs\\QuyTrinh\\change-management.pdf"
  regulations:
    - "D:\\Company-Docs\\PhapLy\\luat-anm-2018.pdf"
    - "D:\\Company-Docs\\PhapLy\\nd-13-2023.pdf"
  standards:
    - "D:\\Company-Docs\\Compliance\\ISO27001\\controls.xlsx"
  policies:
    - "D:\\Company-Docs\\ISMS\\access-control-policy.docx"
  reports:
    - "D:\\Company-Docs\\Reports\\audit-2025-q4.pdf"
  templates:
    - "D:\\Company-Docs\\Templates\\incident-report-template.docx"

# Output paths (where plugin writes generated files)
output:
  profile: "./context/company-profile.yaml"
  workflows: "./workflows"
```

### Step 6: Build company profile từ mapping

Đọc tất cả files trong `mapping.org_docs` → extract thông tin → build profile.

Tương tự flow cũ nhưng đọc từ **mapping paths** thay vì folder cứng:

| Thông tin tìm được | Map vào field |
| --- | --- |
| Tên công ty, ngành, sản phẩm | company.* |
| Cloud, servers, OS | infrastructure.* |
| CI/CD tools, source control | cicd.* |
| Firewall, WAF, VPN | networking.* |
| Database, message queue | data.* |
| SIEM, EDR, scanner | security.* |
| Frameworks, certifications | compliance.* |
| Team size, roles | security_team.* |
| Phòng ban, trưởng phòng, chức năng | org_mapping.* |
| Quy trình escalation, severity contacts | escalation.* |

### Step 7: Hiển thị diff và confirm

Hiển thị **diff** so sánh profile hiện tại vs mới (giống flow cũ):

```diff
--- company-profile.yaml (hiện tại)
+++ company-profile.yaml (sau khi cập nhật)

 company:
-  name: ""
+  name: "ABC Fintech"                    # from: org-chart.xlsx
```

```text
## Summary
  + 5 fields mới
  ~ 2 fields cập nhật
  = 12 fields giữ nguyên
  ○ 3 fields vẫn trống
```

Hỏi user: **Apply? (Yes / Edit / Show full diff / Cancel)**

### Step 8: Write và validate

1. Ghi `company-profile.yaml` vào `output.profile` path
2. Validate:
   - org_mapping có đủ department names?
   - Escalation matrix đủ severity levels?
   - Tech stack consistent?
   - Flag gaps

### Step 9: Q&A fallback

Chạy khi:

- User gõ `skip` ở Step 2 (lần đầu, chưa có gì)
- Sources không có files liên quan
- User chọn "Điền tiếp fields trống qua Q&A" ở Step 0

**Nếu profile trống** — hỏi tất cả:

```text
Tôi sẽ hỏi một số câu để tạo company profile. Bỏ qua câu nào chưa biết.

1. Tên công ty và ngành nghề?
2. Quy mô (số nhân viên, locations)?
3. Cloud/infrastructure đang dùng? (AWS, Azure, on-prem...)
4. Security tools? (SIEM, EDR, firewall, scanner...)
5. Frameworks/certifications đang áp dụng? (ISO 27001, PCI-DSS...)
6. Team security gồm mấy người, roles gì?
7. Có escalation matrix không? (ai nhận alert CRITICAL, HIGH...)
```

**Nếu profile đã có data** — chỉ hỏi fields trống:

```text
Profile đã có 22 fields. Còn 15 fields trống, tôi sẽ hỏi từng nhóm:

## org_mapping (chưa có)
Liệt kê các phòng ban liên quan đến security và trưởng phòng:
  Ví dụ: SOC → Phòng GSANM, lead: Nguyễn Văn A

## escalation (chưa có)
Quy trình escalation theo severity:
  Ví dụ: CRITICAL → notify CISO + CTO, SLA 15 phút
```

Từ câu trả lời → populate profile → **hiển thị diff** → confirm (Step 7).

## Lưu ý

- **Đọc tại chỗ** — KHÔNG copy/move files của user. Plugin chỉ đọc từ original paths.
- **Không ghi đè** field đã có bằng giá trị trống
- **Preserve user edits** — ưu tiên giá trị user đã sửa trực tiếp
- **Cite sources** — ghi rõ file nào cung cấp thông tin gì
- **Redact check** — cảnh báo nếu phát hiện credentials/PII thật
- **Hỗ trợ file types** — `.md`, `.txt`, `.docx`, `.pdf`, `.xlsx`, `.csv`, `.yaml`, `.json`, `.png`, `.jpg`
