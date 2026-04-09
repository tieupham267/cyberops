# CyberOps Plugin — Getting Started

Hướng dẫn cài đặt và cấu hình plugin **cyberops** cho team cybersecurity.

Sau khi hoàn thành, plugin sẽ được tailored cho tổ chức của bạn — tất cả agents sẽ tự động đọc tech stack, org structure, quy trình nội bộ, và quy định applicable để tạo output chính xác.

---

## Tổng quan các bước

| Bước | Nội dung | Thời gian |
| --- | --- | --- |
| 1 | Cài đặt plugin | 5 phút |
| 2 | Khởi tạo data (context, workflows, references) | 5 phút |
| 3 | Setup company profile | 15 phút |
| 4 | Setup org structure & escalation | 10 phút |
| 5 | Setup workflows từ quy trình nội bộ | 10 phút |
| 6 | Thêm tài liệu tham chiếu (regulations, policies) | 10 phút |
| 7 | Cài Office Document Skills *(tùy chọn)* | 10 phút |
| 8 | Verify & test | 5 phút |
| | **Tổng** | **~70 phút** |

---

## Bước 1: Cài đặt plugin

### Yêu cầu hệ thống

- **Claude Code** — VS Code extension (`anthropic.claude-code`) hoặc CLI (`npm install -g @anthropic-ai/claude-code`)
- **Windows**: Git Bash (cài cùng Git for Windows) — cần cho hook scripts
- **Subscription**: Claude Pro hoặc Max

### Cài đặt

**Cách 1 — Cài global** *(recommended cho daily use)*

```text
/plugin marketplace add https://github.com/tieupham267/cyberops
/plugin install cyberops@cyberops
```

Plugin tự load ở mọi project. Data (context, workflows, references) sẽ được khởi tạo ở Bước 2.

**Cách 2 — Clone repo** *(recommended cho dev/contribute)*

```bash
git clone https://github.com/tieupham267/cyberops.git
cd cyberops
claude --plugin-dir .
```

Data đã có sẵn trong repo, có thể bỏ qua Bước 2.

### Nâng cấp từ secops (v2-v3)

Nếu đã cài phiên bản cũ với tên `secops`, cần gỡ và cài lại.

```text
# Gỡ phiên bản cũ
/plugin uninstall secops@secops --scope user
/plugin marketplace remove secops

# Cài cyberops
/plugin marketplace add https://github.com/tieupham267/cyberops
/plugin install cyberops@cyberops
```

Data (context, workflows, references) không bị ảnh hưởng — chỉ đổi tên plugin. Thay đổi:

- Commands: `/secops:*` → `/cyberops:*`
- Config: `~/.claude/secops.yaml` → `~/.claude/cyberops.yaml`
- Env: `SECOPS_PROFILE` → `CYBEROPS_PROFILE`

### Update plugin

```text
/plugin update cyberops
```

Plugin sẽ pull phiên bản mới nhất từ GitHub. Data không bị ảnh hưởng.

### Gỡ cài đặt

```text
# Chọn đúng scope đã cài
/plugin uninstall cyberops@cyberops --scope user
/plugin uninstall cyberops@cyberops --scope project
```

Gỡ plugin khỏi Claude Code. Data tại `context/`, `workflows/`, `references/` vẫn được giữ nguyên — xóa thủ công nếu muốn.

Gỡ marketplace (nếu không dùng nữa):

```text
/plugin marketplace remove cyberops
```

### Verify cài đặt

```text
/cyberops:run --list
```

Nếu thấy danh sách workflows → cài đặt thành công.

---

## Bước 2: Scan tài liệu và build profile

Plugin **không bắt buộc cấu trúc folder cứng**. Bạn chỉ cần chỉ tới nơi tài liệu đang lưu — plugin tự scan, phân loại, và build mapping.

### Chạy setup

```text
/cyberops:setup-profile
```

### Plugin sẽ hỏi folder(s) chứa tài liệu

```text
Chỉ tôi tới folder(s) chứa tài liệu tổ chức của bạn.
Có thể nhiều folders, mỗi dòng một path.

Ví dụ:
  D:\Company-Docs
  \\fileserver\IT-Department
  C:\Users\you\OneDrive\Work

Paths:
```

### Plugin tự scan và phân loại

Plugin đọc tất cả files, phân tích nội dung, và phân loại vào categories:

| Category | Nội dung | Plugin dùng để |
| --- | --- | --- |
| `org_docs` | Sơ đồ tổ chức, tech stack, asset inventory | Build company profile |
| `process_docs` | SOPs, playbooks, runbooks | Generate workflows |
| `regulations` | Luật, NĐ, TT | Tra cứu quy định |
| `standards` | ISO, PCI, NIST controls | Gap analysis |
| `policies` | ISMS, chính sách nội bộ | Compliance check |
| `reports` | Audit reports, assessments | Trend analysis |
| `templates` | Mẫu biểu, forms | Document drafting |

### Hiển thị kết quả scan → confirm

```text
## Scan Results — 47 files found

org_docs (8):     IT/org-chart.xlsx, IT/tech-stack.md, ...
process_docs (12): QuyTrinh/incident-response-sop.docx, ...
regulations (5):  PhapLy/luat-anm-2018.pdf, ...
policies (6):     ISMS/access-control-policy.docx, ...
standards (3):    Compliance/ISO27001/controls.xlsx, ...

Confirm mapping? [Yes / Edit / Rescan]
```

Bạn có thể **Edit** để di chuyển files giữa categories hoặc skip files không liên quan.

### Build company profile

Sau khi confirm mapping, plugin đọc `org_docs` → extract thông tin → hiển thị **diff** → confirm → lưu `company-profile.yaml`.

### Mapping được lưu global

Mapping lưu vào `~/.claude/cyberops.yaml` — mọi session sau tự đọc, không cần scan lại:

```yaml
# ~/.claude/cyberops.yaml
sources:
  - path: "D:\\Company-Docs"
    scanned_at: "2026-04-09T10:30:00"

mapping:
  org_docs:
    - "D:\\Company-Docs\\IT\\org-chart.xlsx"
    - "D:\\Company-Docs\\IT\\tech-stack.md"
  process_docs:
    - "D:\\Company-Docs\\QuyTrinh\\incident-response-sop.docx"
  # ...

output:
  profile: "./context/company-profile.yaml"
  workflows: "./workflows"
```

### Cập nhật khi tài liệu thay đổi

```text
/cyberops:setup-profile              # Rescan + rebuild profile
/cyberops:config rescan              # Chỉ rescan mapping, không rebuild
/cyberops:config add-source D:\New   # Thêm folder mới
```

### Cách khác: điền thủ công hoặc Q&A

Nếu không muốn scan:

```text
# Điền trực tiếp vào company-profile.yaml
Mở context/company-profile.yaml và điền các fields

# Hoặc nhờ Claude hỏi Q&A
Đọc file context/company-profile.yaml, tôi sẽ trả lời câu hỏi để bạn điền giúp.
```

---

## Bước 4: Setup Org Structure & Escalation

Org mapping giúp workflows gán action items đúng phòng ban + đúng người.

### Điền `org_mapping`

Mở `context/company-profile.yaml`, tìm section `org_mapping`:

```yaml
org_mapping:
  soc:
    department: "Phòng GSANM"          # Tên phòng ban thực tế
    lead: "Nguyễn Văn A"               # Trưởng phòng / contact
  network:
    department: "Phòng Hạ tầng"
    lead: "Trần Văn B"
  devops:
    department: "Phòng DevOps"
    lead: "Lê Văn C"
  # ... thêm các phòng ban khác
```

### Điền `escalation`

```yaml
escalation:
  - severity: CRITICAL
    notify: ["CISO", "CTO", "CEO"]
    channel: "Slack #incident-critical + Phone call"
    sla: "15 phút"
  - severity: HIGH
    notify: ["CISO", "IT Director"]
    channel: "Slack #security-alerts"
    sla: "1 giờ"
  # ... thêm các mức severity khác
```

> Để trống nếu chưa có → workflows dùng tên generic và flag "(chưa xác định phòng ban)".

---

## Bước 5: Setup Workflows

### Default workflows (sẵn sàng dùng ngay)

Plugin đi kèm 10 default workflows:

| Workflow | Mục đích |
| --- | --- |
| `incident-response-default` | Ứng phó sự cố (NIST 800-61) |
| `data-breach-notification-default` | Thông báo vi phạm DLCN (NĐ 13/2023, 72h) |
| `vuln-management-default` | Xử lý lỗ hổng bảo mật |
| `access-review-default` | Rà soát quyền truy cập |
| `change-management-default` | Quản lý thay đổi |
| `vendor-risk-default` | Đánh giá rủi ro vendor |
| `bcdr-drill-default` | Diễn tập BCP/DRP |
| `security-awareness-default` | Đào tạo nhận thức ATTT |
| `risk-assessment-default` | Đánh giá rủi ro CNTT |
| `fraud-investigation-default` | Điều tra gian lận |

### Tạo custom workflows từ quy trình nội bộ

Nếu mapping đã có `process_docs` (từ Bước 2), chạy:

```text
/cyberops:generate-workflows
```

Plugin đọc tất cả files trong `mapping.process_docs`, phân tích quy trình, và tạo workflow YAML tương ứng. Hiển thị preview + **diff** → confirm → tạo/cập nhật.

> Custom workflows tự động **override** default workflows cùng loại.

### Cập nhật khi quy trình thay đổi

1. Sửa/thêm process docs vào source folders (hoặc chạy `/cyberops:config rescan`)
2. Chạy lại `/cyberops:generate-workflows`
3. Review diff → confirm

---

## Bước 6: Review tổ chức tài liệu *(tùy chọn)*

Plugin có thể đánh giá cách sắp xếp tài liệu và đề xuất cải thiện.

```text
/cyberops:doc-review
```

### Chọn framework đánh giá

| Framework | Mô tả |
| --- | --- |
| **PARA (Second Brain)** | Projects / Areas / Resources / Archive — phân loại theo actionability |
| **Security-focused** | Governance / Operations / Technical / Compliance / Evidence |
| **ISO 27001 Hierarchy** | Policies → Standards → Procedures → Guidelines → Records |
| **Custom** | Mô tả cách bạn muốn sắp xếp |

### Plugin sẽ phân tích

- Phân loại mỗi file theo framework đã chọn
- Phát hiện files outdated (> 12 tháng chưa review)
- Gap analysis — tài liệu nào thiếu theo compliance requirements
- Phát hiện duplicate/conflict
- Đề xuất action plan có ưu tiên

### Ví dụ output (PARA)

```text
Projects (đang active):  3 files — incident đang xử lý, audit prep
Areas (ongoing):         15 files — policies, SOPs, audit evidence, vendor assessments
  ⚠️ 3 files chưa review > 12 tháng
Resources (tham khảo):   8 files — regulations, frameworks
Archive (không còn sử dụng): 2 files — superseded, deprecated
```

### Tra cứu tài liệu tham chiếu

Khi agents cần tra cứu luật, quy định, tiêu chuẩn:

1. **`skills/`** (bundled) — knowledge base chuẩn đi kèm plugin
2. **`mapping`** files (`regulations`, `standards`, `policies`) — tài liệu user đã scan
3. **Web search** — chỉ khi cả 2 nguồn trên không đủ

Knowledge base bundled sẵn:

| Nội dung | Skill |
| --- | --- |
| Luật ANM 2018, NĐ 13/2023, NĐ 85/2016, TT 09/2020 | `skills/vietnam-regulations/` |
| ISO 27001, NIST CSF, CIS v8 | `skills/compliance-frameworks/` |

---

## Bước 7: Cài Office Document Skills *(tùy chọn)*

Cần khi xuất tài liệu dạng Word (.docx), PowerPoint (.pptx), hoặc Excel (.xlsx).

> Bỏ qua nếu chỉ cần output Markdown.

### Khi nào cần?

- Báo cáo đánh giá rủi ro gửi NHNN (.docx)
- Slide trình bày cho Board (.pptx)
- Risk register, vulnerability tracker (.xlsx)
- Policy/SOP theo template công ty (.docx)

### Cài Office Document Skills

```text
# Đăng ký marketplace
/plugin marketplace add anthropics/skills

# Cài document-skills
/plugin install document-skills@anthropic-agent-skills
```

Hoặc qua UI: `/plugin` → **Browse and install plugins** → **anthropic-agent-skills** → **document-skills** → **Install now**

### Dependencies

| Skill | Cài đặt |
| --- | --- |
| **docx** | `npm install -g docx` |
| **pptx** | `npm install -g pptxgenjs` và `pip install "markitdown[pptx]" Pillow` |
| **xlsx** | `pip install openpyxl pandas` |

LibreOffice *(PDF conversion)*:

```bash
# Ubuntu/Debian
sudo apt install libreoffice-calc libreoffice-writer libreoffice-impress

# macOS
brew install --cask libreoffice

# Windows — download từ libreoffice.org
```

### Verify dependencies

```bash
node -e "require('docx'); console.log('docx OK')"
node -e "require('pptxgenjs'); console.log('pptx OK')"
python -c "import openpyxl; print('xlsx OK')"
```

### Cách hoạt động

Agents tự quyết định khi nào dùng Office format dựa vào context. Nếu chưa cài skill mà user yêu cầu → agent output Markdown + thông báo cài skill.

---

## Bước 8: Verify & Test

### Chạy test suite

```bash
bash tests/run-all.sh
```

5 layers phải pass:

| Layer | Kiểm tra |
| --- | --- |
| 1 — Structural Integrity | Cấu trúc plugin, frontmatter, YAML schemas |
| 2 — Hook Functionality | Mỗi hook script block/allow đúng |
| 3 — Output Quality | Agents có đủ sections, bilingual |
| 4 — Orchestration Flow | Routing, workflow uniqueness, chain consistency |
| 5 — Plugin Security | Không secrets, không injection |

### Test thử workflow

```text
/cyberops:run alert-triage
```

Orchestrator hỏi input → trả lời → nhận output tailored cho tech stack → setup thành công.

### Test hook

```text
Tạo file test.txt có nội dung: password = "MySecret123"
```

Hook phải block và hiện thông báo `[SECURITY]`.

---

## Quick Reference

### Commands

| Command | Mục đích |
| --- | --- |
| `/cyberops:run <workflow>` | Chạy workflow cụ thể |
| `/cyberops:run <mô tả>` | Mô tả tự nhiên → orchestrator tự chọn workflow |
| `/cyberops:run --list` | Liệt kê tất cả workflows |
| `/cyberops:setup-profile` | Scan tài liệu, build mapping + company profile |
| `/cyberops:generate-workflows` | Tạo/cập nhật workflows từ process docs |
| `/cyberops:doc-review` | Review tổ chức tài liệu (PARA, ISO, custom) |
| `/cyberops:config` | Quản lý sources, mapping, output paths |

### Environment Variable

| Biến | Mục đích | Giá trị |
| --- | --- | --- |
| `CYBEROPS_PROFILE` | Mức độ nghiêm ngặt của hooks | `dev` / `standard` *(default)* / `strict` |

```bash
CYBEROPS_PROFILE=dev claude        # Nhẹ — chỉ check secrets
CYBEROPS_PROFILE=strict claude     # Nghiêm ngặt — block cả warnings
```

### Global Config

File `~/.claude/cyberops.yaml` — document sources, mapping, và output paths:

```yaml
sources:
  - path: "D:\\Company-Docs"
mapping:
  org_docs: [...]
  process_docs: [...]
  regulations: [...]
output:
  profile: "./context/company-profile.yaml"
  workflows: "./workflows"
```

Không có file này → plugin hỏi khi chạy `/cyberops:setup-profile` lần đầu.

### Document Mapping Categories

| Category | Nội dung | Plugin dùng để |
| --- | --- | --- |
| `org_docs` | Sơ đồ, tech stack, teams | Build company profile |
| `process_docs` | SOPs, playbooks | Generate workflows |
| `regulations` | Luật, NĐ, TT | Tra cứu quy định |
| `standards` | ISO, PCI, NIST | Gap analysis |
| `policies` | ISMS, chính sách nội bộ | Compliance check |
| `reports` | Audit, assessment | Trend analysis |
| `templates` | Mẫu biểu | Document drafting |

---

## Tài liệu liên quan

| Tài liệu | Nội dung |
| --- | --- |
| [CLAUDE.md](CLAUDE.md) | Technical reference — architecture, design patterns, rules |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Hướng dẫn phát triển và contribute plugin |
| `workflows/SCHEMA.md` | Format YAML cho workflow templates |
