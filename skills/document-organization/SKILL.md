---
name: document-organization
description: >
  Document organization and knowledge management methodology for cybersecurity teams.
  Covers: PARA (Second Brain by Tiago Forte), ISO 27001 document hierarchy, security-focused
  taxonomy, lifecycle management, version control, and review cycles. Use when reviewing,
  reorganizing, or assessing document structure. Supports Vietnamese and English content.
---

# Document Organization — Skill

## Mục đích

Cung cấp methodology để đánh giá, tổ chức, và duy trì hệ thống tài liệu bảo mật. Dùng khi `/secops:doc-review` hoặc khi cần đánh giá document maturity.

---

## Framework 1: PARA (Second Brain)

Phương pháp của Tiago Forte. Phân loại tài liệu theo **mức độ actionability** — từ urgent nhất tới ít active nhất.

### 4 Categories

| Category | Định nghĩa | Đặc điểm | Ví dụ SecOps |
| --- | --- | --- | --- |
| **Projects** | Mục tiêu cụ thể + deadline | Active, time-bound, có deliverable rõ ràng | Incident đang xử lý, audit prep Q2, SIEM migration |
| **Areas** | Trách nhiệm ongoing | Không deadline, cần maintain liên tục | ISMS maintenance, SOC operations, vuln mgmt, policy review |
| **Resources** | Tài liệu tham khảo | Knowledge base, không cần action | Frameworks (ISO, NIST), regulations, training materials, templates |
| **Archive** | Hoàn thành / không active | Giữ để tham khảo, không cần truy cập thường xuyên | Old audits, closed incidents, deprecated policies, retired SOPs |

### Quy tắc phân loại

1. **Có deadline + đang active?** → Projects
2. **Không deadline nhưng phải maintain?** → Areas
3. **Chỉ để tham khảo?** → Resources
4. **Đã xong / không dùng nữa?** → Archive

### Quy tắc di chuyển (lifecycle)

```text
Resources → Areas    (khi bắt đầu áp dụng framework vào tổ chức)
Areas → Projects     (khi có task cụ thể + deadline)
Projects → Archive   (khi hoàn thành)
Areas → Archive      (khi trách nhiệm thay đổi)
```

### PARA cho SecOps — Best Practices

**Projects:**
- Mỗi project = 1 folder riêng
- Gom tất cả related files (emails, notes, deliverables)
- Có file `README.md` hoặc `status.md` tracking progress
- Archive toàn bộ folder khi hoàn thành

**Areas:**
- Tổ chức theo function (SOC, GRC, IR, DevSecOps) hoặc theo document type (policies, SOPs)
- Mỗi file có owner + review schedule
- Flag files chưa review > review cycle (thường 12 tháng)

**Resources:**
- Tổ chức theo topic (regulations, frameworks, vendor docs, training)
- Không cần owner — ai cũng có thể đọc
- Update khi có version mới (ví dụ: ISO 27001:2013 → 2022)

**Archive:**
- Tổ chức theo năm hoặc theo project name
- Read-only — không sửa
- Retention policy: giữ bao lâu? (compliance requirement)

---

## Framework 2: ISO 27001 Document Hierarchy

Pyramid 5 cấp — từ high-level tới chi tiết.

### 5 Levels

```text
┌─────────────────────────────┐
│   Level 1: POLICIES         │  ← What (tuyên bố ý định, mục tiêu)
│   "Chính sách ATTT"        │
├─────────────────────────────┤
│   Level 2: STANDARDS        │  ← What specifically (yêu cầu cụ thể, đo lường được)
│   "Tiêu chuẩn mật khẩu"   │
├─────────────────────────────┤
│   Level 3: PROCEDURES       │  ← How (các bước thực hiện, SOP)
│   "Quy trình reset MK"     │
├─────────────────────────────┤
│   Level 4: GUIDELINES       │  ← How (suggested, không bắt buộc)
│   "Hướng dẫn chọn MK"      │
├─────────────────────────────┤
│   Level 5: RECORDS          │  ← Proof (bằng chứng thực hiện)
│   "Log MK đã reset"        │
└─────────────────────────────┘
```

### Đặc điểm từng level

| Level | Document type | Approve bởi | Review cycle | Ví dụ |
| --- | --- | --- | --- | --- |
| 1 — Policy | Tuyên bố ý định, scope, objectives | Board / CEO / CISO | 1-2 năm | ISMS Policy, Access Control Policy |
| 2 — Standard | Yêu cầu cụ thể, measurable | CISO / Department Head | 1 năm | Password Standard, Encryption Standard |
| 3 — Procedure | Step-by-step SOP | Process Owner | 6-12 tháng | Incident Response SOP, Change Mgmt SOP |
| 4 — Guideline | Best practice, khuyến nghị | Author / SME | Khi cần | Secure Coding Guide, Remote Work Guide |
| 5 — Record | Evidence, log, form đã điền | Automatic / Operator | Retention policy | Audit logs, approval forms, training certs |

### Completeness Check

Với mỗi Policy (Level 1), kiểm tra:

```text
Policy: Access Control
  ✓ Standard: Password requirements, MFA requirements
  ✓ Procedure: Account provisioning SOP, access review SOP
  ✓ Guideline: Remote access guide
  ✗ Records: Chưa có access review records ← GAP
```

### ISO 27001:2022 Required Documents

| Clause | Document | Level |
| --- | --- | --- |
| 4.3 | Scope of ISMS | Policy |
| 5.2 | Information Security Policy | Policy |
| 6.1.2 | Risk Assessment Process | Procedure |
| 6.1.3 | Risk Treatment Plan | Record |
| A.5.1 | Information Security Policies | Policy |
| A.5.10 | Acceptable Use of Assets | Policy/Standard |
| A.5.12 | Classification of Information | Standard/Procedure |
| A.5.23 | Information Security for Cloud Services | Standard |
| A.5.24 | Incident Management Planning | Procedure |
| A.5.29 | Business Continuity | Procedure |
| A.6.1 | Screening | Procedure |
| A.8.1 | User Endpoint Devices | Standard |
| A.8.9 | Configuration Management | Procedure |
| A.8.24 | Cryptography | Standard |

---

## Framework 3: Security-focused Taxonomy

Phân loại theo 5 domain bảo mật — phù hợp team không theo ISO strict.

### 5 Domains

| Domain | Scope | Ví dụ documents |
| --- | --- | --- |
| **Governance** | Strategy, policy, org structure, roles | ISMS Policy, Security Charter, Org Chart, RACI matrix |
| **Operations** | Day-to-day procedures | SOPs, playbooks, runbooks, checklists, escalation matrix |
| **Technical** | Architecture, configs, specs | Network diagrams, firewall rules, hardening guides, API specs |
| **Compliance** | Audit, regulatory, evidence | Audit reports, gap analysis, regulatory filings, certifications |
| **Evidence** | Proof of implementation | Screenshots, logs, approval emails, training records, meeting minutes |

---

## Document Lifecycle Management

### Lifecycle Stages

```text
Draft → Review → Approved → Published → In Use → Review Due → Updated/Retired
```

### Metadata mỗi document nên có

| Field | Mô tả | Bắt buộc |
| --- | --- | --- |
| `title` | Tên tài liệu | Yes |
| `doc_id` | Mã tài liệu (ví dụ: POL-SEC-001) | Recommended |
| `version` | Số version (ví dụ: 2.1) | Yes |
| `status` | Draft / Approved / Published / Retired | Yes |
| `owner` | Người chịu trách nhiệm | Yes |
| `author` | Người soạn thảo | Recommended |
| `approved_by` | Người phê duyệt | Yes (cho Policy, Standard) |
| `effective_date` | Ngày có hiệu lực | Yes |
| `review_date` | Ngày review tiếp theo | Yes |
| `classification` | TLP / Internal / Confidential | Yes |
| `change_log` | Lịch sử thay đổi | Recommended |

### Review Cycle theo loại

| Document type | Review cycle | Trigger review sớm |
| --- | --- | --- |
| Policy | 12-24 tháng | Regulatory change, org restructure |
| Standard | 12 tháng | Technology change, incident lessons |
| SOP / Procedure | 6-12 tháng | Process change, audit finding |
| Guideline | Khi cần | New technology, best practice update |
| Records | Retention policy | N/A |

---

## Document Numbering Convention

### Recommended scheme

```text
[TYPE]-[DOMAIN]-[SEQ]

TYPE:
  POL = Policy
  STD = Standard
  SOP = Procedure/SOP
  GDL = Guideline
  REC = Record
  TPL = Template
  RPT = Report

DOMAIN:
  SEC = Information Security
  ACC = Access Control
  INC = Incident Response
  CHG = Change Management
  NET = Network Security
  DAT = Data Protection
  BCP = Business Continuity
  HR  = Human Resources Security

Ví dụ:
  POL-SEC-001 = Information Security Policy
  SOP-INC-003 = Incident Containment Procedure
  STD-ACC-002 = Multi-Factor Authentication Standard
```

---

## Gap Analysis Checklist

Khi review document structure, kiểm tra:

### Completeness

- [ ] Mỗi security function có ít nhất 1 policy?
- [ ] Mỗi policy có standard + procedure tương ứng?
- [ ] Có evidence/records cho mỗi control đang implement?
- [ ] Regulatory requirements đã có documents coverage?
- [ ] All critical processes có SOP?

### Quality

- [ ] Documents có metadata đầy đủ (owner, version, review date)?
- [ ] Không có documents quá hạn review?
- [ ] Không có duplicate/conflicting documents?
- [ ] Terminology nhất quán across documents?
- [ ] Classification marking đầy đủ?

### Accessibility

- [ ] Team members biết tìm documents ở đâu?
- [ ] Có document index/registry?
- [ ] Access control phù hợp (ai được đọc gì)?
- [ ] Backup/versioning cho documents quan trọng?

### Compliance Mapping

- [ ] ISO 27001 clause → document mapping complete?
- [ ] Vietnamese regulations → document mapping complete?
- [ ] Industry-specific requirements (PCI, NHNN) → covered?

---

## Assessment Scoring

Khi đánh giá document maturity:

| Score | Level | Mô tả |
| --- | --- | --- |
| 1 | Initial | Ad-hoc, không có cấu trúc, thiếu nhiều documents |
| 2 | Developing | Có một số documents nhưng thiếu consistency, nhiều gaps |
| 3 | Defined | Cấu trúc rõ ràng, phần lớn documents có đủ metadata, một số gaps |
| 4 | Managed | Đầy đủ, có review cycle, version control, minimal gaps |
| 5 | Optimizing | Automated review reminders, metrics tracking, continuous improvement |

### Scoring criteria

| Dimension | 1 | 3 | 5 |
| --- | --- | --- | --- |
| **Coverage** | < 30% controls covered | 60-80% covered | > 95% covered |
| **Currency** | > 50% outdated | < 20% outdated | 100% current |
| **Quality** | No metadata | Partial metadata | Full metadata + version control |
| **Accessibility** | Scattered, no index | Central location | Searchable registry + access control |
| **Compliance** | No mapping | Partial mapping | Full mapping + evidence |
