# /cyberops:doc-review — Review và đề xuất tổ chức tài liệu

**ALWAYS read `skills/document-organization/SKILL.md`** trước khi thực hiện review. Skill này chứa methodology chi tiết cho PARA, ISO 27001, Security-focused, gap analysis checklist, và scoring criteria.

Bạn đang review cách tổ chức tài liệu của user và đề xuất cải thiện theo framework đã chọn.

## Quy trình

### Step 0: Đọc mapping hiện tại

Đọc `~/.claude/cyberops.yaml` để lấy `sources` và `mapping`. Nếu chưa có → hướng dẫn chạy `/cyberops:setup-profile` trước.

### Step 1: Hỏi framework

```text
Bạn muốn review tài liệu theo framework nào?

1. PARA (Second Brain by Tiago Forte)
   Projects / Areas / Resources / Archive

2. Security-focused
   Governance / Operations / Technical / Compliance / Evidence

3. ISO 27001 Document Hierarchy
   Policies → Standards → Procedures → Guidelines → Records

4. Custom — mô tả cách bạn muốn sắp xếp

Chọn [1/2/3/4]:
```

### Step 2: Scan và phân tích

Đọc tất cả files từ `sources`. Với mỗi file, xác định:

- **Nội dung chính** (summary)
- **Loại tài liệu** (policy, SOP, report, template, reference...)
- **Trạng thái** (active/draft/outdated/archive)
- **Liên kết** (references tới files khác, frameworks, regulations)
- **Chất lượng** (có đủ sections cần thiết không, có outdated không)

### Step 3: Đánh giá theo framework đã chọn

---

## Framework 1: PARA (Second Brain)

Map mỗi file vào 1 trong 4 categories:

| PARA | Định nghĩa | Ví dụ CyberOps |
| --- | --- | --- |
| **Projects** | Có deadline, đang active, cần hành động | Incident đang xử lý, audit prep Q2, migration plan |
| **Areas** | Trách nhiệm ongoing, không có deadline | ISMS maintenance, SOC operations, vulnerability mgmt, pentest reports (audit evidence), vendor assessments, regulatory correspondence |
| **Resources** | Tài liệu tham khảo, knowledge base | Frameworks (ISO, NIST), training materials, templates |
| **Archive** | Không còn giá trị sử dụng cho area nào | Deprecated policies đã thay thế, superseded documents, incidents đã close + không cần cho audit |

**Output:**

```text
## PARA Analysis

### Projects (đang active, cần hành động)
  📋 incident-2025-003-response.md — IR đang xử lý, deadline: 2025-04-15
  📋 iso27001-recertification.xlsx — Audit prep, deadline: 2025-06-30
  📋 siem-migration-plan.md — Migration to OpenSearch

### Areas (trách nhiệm ongoing)
  🔄 access-control-policy.docx — ISMS, review cycle: annual
  🔄 incident-response-sop.docx — SOC Operations
  🔄 vulnerability-management-process.md — Vuln Mgmt
  🔄 audit-report-2023.pdf — VAPT & Audit (PCI-DSS evidence, retest reference)
  🔄 vendor-risk-assessment-2024.xlsx — Risk Management (ongoing vendor risk)
  🔄 cong-van-nhnn-2024.pdf — Risk Management (SBV audit reference)
  ⚠️ change-management.pdf — Chưa review > 12 tháng

### Resources (tham khảo)
  📚 luat-anm-2018.pdf — Regulation
  📚 iso27001-controls.xlsx — Framework
  📚 nist-csf-mapping.md — Framework

### Archive (không còn giá trị sử dụng)
  📦 old-network-diagram-v1.png — Superseded by v3
  📦 access-policy-v1.docx — Deprecated, replaced by v2
  📦 incident-2023-005-postmortem.md — Closed, lessons learned đã extract

### Đề xuất
  1. ⚠️ 3 files trong Areas chưa review > 12 tháng → cần review/update
  2. 🔄 2 SOPs thiếu version control → thêm version + review date
  3. ❌ 0 Projects có deadline tracking → nên thêm deadline metadata
```

---

## Framework 2: Security-focused

Map theo domains bảo mật:

| Domain | Nội dung |
| --- | --- |
| **Governance** | Policies, standards, charters, org structure, roles & responsibilities |
| **Operations** | SOPs, playbooks, runbooks, operational procedures |
| **Technical** | Architecture docs, configurations, tech specs, diagrams |
| **Compliance** | Audit reports, evidence, regulatory filings, gap analysis |
| **Evidence** | Logs, screenshots, approval records, training records |

---

## Framework 3: ISO 27001 Document Hierarchy

Map theo pyramid:

```text
Level 1: Policies          (What — tuyên bố ý định)
Level 2: Standards         (What specifically — yêu cầu cụ thể)
Level 3: Procedures/SOPs   (How — cách thực hiện)
Level 4: Guidelines        (How suggested — hướng dẫn khuyến nghị)
Level 5: Records/Evidence  (Proof — bằng chứng thực hiện)
```

**Kiểm tra bổ sung:**

- Mỗi Policy có Standard tương ứng không?
- Mỗi Standard có Procedure không?
- Có evidence cho mỗi control?
- Document numbering nhất quán?

---

## Framework 4: Custom

Hỏi user mô tả cách muốn sắp xếp:

```text
Mô tả cách bạn muốn tổ chức tài liệu.

Ví dụ:
- "Theo phòng ban: IT, HR, Legal, Finance"
- "Theo lifecycle: Draft → Review → Approved → Archive"
- "Theo project: từng dự án một folder riêng"
- "Kết hợp PARA + theo phòng ban"

Mô tả:
```

Từ mô tả, tạo custom categories và map files vào.

### Step 4: Gap Analysis

Dù chọn framework nào, luôn kiểm tra:

```text
## Gap Analysis

### Thiếu hoàn toàn (không tìm thấy)
  ❌ Data Classification Policy — Required by NĐ 13/2023, ISO 27001 A.5.12
  ❌ Business Continuity Plan — Required by ISO 27001 A.5.29
  ❌ Supplier Security Policy — Required by ISO 27001 A.5.19-5.22

### Outdated (> 12 tháng chưa review)
  ⚠️ access-control-policy.docx — Last modified: 2024-01-15
  ⚠️ network-diagram.png — Last modified: 2023-11-20

### Thiếu elements quan trọng
  ⚠️ incident-response-sop.docx — Thiếu: version, owner, review date
  ⚠️ change-management.pdf — Thiếu: approval signature, effective date

### Duplicate/Conflict
  🔄 Two access control policies found — cần merge hoặc deprecate 1
```

### Step 5: Đề xuất action plan

```text
## Action Plan (ưu tiên theo risk)

| # | Action | Priority | Owner suggestion | Effort |
|---|--------|----------|-----------------|--------|
| 1 | Tạo Data Classification Policy | HIGH | GRC / Compliance | 2-3 ngày |
| 2 | Review 3 policies outdated > 12 tháng | HIGH | Policy owners | 1 ngày/policy |
| 3 | Archive 5 files không còn active | LOW | Document admin | 1 giờ |
| 4 | Thêm version control cho 8 SOPs | MEDIUM | Process owners | 2 giờ/SOP |
| 5 | Tạo BCP/DRP | HIGH | CISO + BU heads | 1-2 tuần |

Bạn muốn tôi giúp thực hiện action nào?
```

### Step 6 (optional): Thực hiện reorganization

Nếu user muốn reorganize:

1. **Chỉ đề xuất** folder structure mới — KHÔNG tự di chuyển files
2. Hiển thị plan di chuyển:

   ```text
   ## Proposed Reorganization

   Từ:  D:\Company-Docs\Misc\meeting-notes-2025.md
   Tới: D:\Company-Docs\Projects\iso-audit-2025\meeting-notes.md

   Từ:  D:\Company-Docs\old-stuff\audit-2023.pdf
   Tới: D:\Company-Docs\Archive\2023\audit-report.pdf

   Apply? [Yes / Edit / Cancel]
   ```

3. Nếu confirm → thực hiện di chuyển + cập nhật mapping trong `cyberops.yaml`

## Lưu ý

- **KHÔNG tự di chuyển files** mà không có confirm từ user
- **Đọc tại chỗ** — scan từ original paths
- Review nên dựa trên **nội dung thực tế**, không chỉ tên file
- Khi đề xuất structure mới, giải thích **tại sao** (reference framework)
- Gap analysis dựa trên `company-profile.yaml` (industry, compliance requirements)
- Output bằng ngôn ngữ user đang dùng (Việt/Anh)
