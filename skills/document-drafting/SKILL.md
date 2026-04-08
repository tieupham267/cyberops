---
name: document-drafting
description: >
  Professional document drafting discipline for cybersecurity documents.
  Covers: security policies, SOPs/procedures, assessment reports, regulatory filings,
  official admin letters (công văn), training materials. Enforces accuracy (placeholders
  for missing info), consistency, and Vietnamese document standards (NĐ 30/2020).
  Use when ANY agent needs to produce a formal document. Shared skill across all agents.
---

# Document Drafting — Shared Skill

## Mục đích

Chuẩn hóa cách soạn thảo tài liệu bảo mật cho tất cả agents. Bất kỳ agent nào cần produce formal document → đọc skill này trước khi soạn.

## Nguyên tắc cốt lõi

### 1. Accuracy — Chính xác

- **CHỈ** dùng thông tin được cung cấp hoặc có trong company-profile.yaml
- **KHÔNG BAO GIỜ** bịa số liệu, ngày tháng, tên hệ thống, tên người, sự kiện
- Thiếu thông tin → đánh dấu placeholder: `[NEEDS INPUT: mô tả thông tin cần]`
- Không chắc chắn → ghi rõ: `[VERIFY: thông tin này cần xác nhận]`

### 2. Consistency — Nhất quán

- Thuật ngữ thống nhất xuyên suốt tài liệu (không dùng "ATTT" rồi lại "an toàn thông tin")
- Font, numbering, formatting theo quy ước đã chọn
- Tone phù hợp loại tài liệu (policy = directive, SOP = descriptive, report = analytical)
- Loại bỏ lặp lại — mỗi section phải có nội dung mới, không restate section trước
- Viết hoa: tiêu đề Title Case, body Sentence case

### 3. Professionalism — Chuyên nghiệp

- Ngôn ngữ rõ ràng, chính xác, không mơ hồ
- Cấu trúc logic, dễ theo dõi
- Phù hợp đối tượng đọc (internal stakeholders)

## Document Types & Required Structure

### Type 1: Security Assessment / Technical Report

```
1. Executive Summary
2. Scope (Phạm vi đánh giá)
3. Methodology (Phương pháp)
4. Findings (Phát hiện) — dùng CVSS scoring, sanitize evidence nhạy cảm
5. Risk Summary (Tóm tắt rủi ro) — risk matrix, priority
6. Recommendations (Khuyến nghị) — prioritized
7. Appendix (Phụ lục) — raw data, evidence screenshots
```

**Quy tắc riêng**:
- Mỗi finding: severity + description + evidence + recommendation + owner + deadline
- Sanitize: mask IP nội bộ, hostnames, usernames trong screenshots/evidence trước khi share
- Dùng CVSS v3.1/v4.0 cho vulnerability scoring

### Type 2: Security Policy (Chính sách)

```
1. Purpose (Mục đích)
2. Scope (Phạm vi áp dụng)
3. Definitions (Thuật ngữ)
4. Policy Statements (Điều khoản chính sách)
5. Roles & Responsibilities (Vai trò & Trách nhiệm)
6. Compliance & Violations (Tuân thủ & Vi phạm)
7. Related Documents (Tài liệu liên quan)
8. Version History (Lịch sử phiên bản)
```

**Quy tắc riêng**:
- Ngôn ngữ directive: "phải" (shall), "không được" (must not), "nên" (should)
- Phân biệt mandatory vs recommended
- Map sang framework controls (ISO 27001, NIST CSF, CIS) nếu applicable
- Version history bắt buộc: version, date, author, changes

### Type 3: SOP / Procedure (Quy trình)

```
1. Purpose (Mục đích)
2. Scope (Phạm vi)
3. Reference Documents (Tài liệu tham chiếu)
4. Definitions (Thuật ngữ)
5. Roles & Responsibilities (Vai trò)
6. Detailed Steps (Các bước thực hiện)
7. Exception Handling (Xử lý ngoại lệ)
8. Attached Forms (Biểu mẫu đính kèm)
9. Change History (Lịch sử thay đổi)
```

**Quy tắc riêng**:
- Mỗi bước: **Ai** → làm **gì** → **Output** là gì
- Bao gồm escalation path khi gặp exception
- SLA cho mỗi bước nếu applicable
- Flowchart minh họa nếu quy trình phức tạp (>5 bước hoặc có rẽ nhánh)

### Type 4: Official Administrative Letter (Công văn)

```
1. Quốc hiệu, tiêu ngữ
2. Tên cơ quan / tổ chức ban hành
3. Số hiệu văn bản
4. Ngày, nơi ban hành
5. Trích yếu nội dung
6. Nội dung chính
7. Nơi nhận
8. Chữ ký, chức vụ
```

**Quy tắc riêng**:
- Tuân thủ Nghị định 30/2020/NĐ-CP về công tác văn thư
- Căn cứ pháp lý rõ ràng
- Văn phong hành chính — trang trọng, không dùng khẩu ngữ
- Font: Times New Roman, size 13-14 (theo quy định)

### Type 5: Security Awareness Training Material

```
1. Learning Objectives (Mục tiêu học tập)
2. Target Audience (Đối tượng)
3. Core Content (Nội dung chính)
4. Examples / Scenarios (Ví dụ / Tình huống)
5. Quiz / Assessment (Câu hỏi kiểm tra)
6. References (Tham khảo)
```

**Quy tắc riêng**:
- Ngôn ngữ dễ hiểu cho non-technical users
- Focus vào hành động cụ thể người dùng cần làm (không lý thuyết suông)
- Dùng ví dụ thực tế, phù hợp ngữ cảnh Việt Nam
- Quiz: câu hỏi tình huống, không hỏi lý thuyết

## Workflow soạn thảo

Tuân thủ 5 bước cho mọi yêu cầu soạn thảo:

```
INTAKE    Xác định loại tài liệu · Mục đích · Thu thập thông tin nguồn
   ↓
ANALYZE   Kiểm tra đầy đủ thông tin · Chọn structure · Liệt kê missing info
   ↓
DRAFT     Áp dụng structure chuẩn · CHỈ dùng thông tin đã cung cấp · Đánh dấu placeholder
   ↓
REVIEW    Kiểm tra consistency · Loại bỏ lặp lại · Logic flow · Viết hoa · Thuật ngữ
   ↓
DELIVER   Output theo format bắt buộc bên dưới
```

### Quy tắc hỏi thêm thông tin

Tối đa **2 câu hỏi mỗi lượt**. Quyết định theo bảng:

| Thiếu thông tin | Hành động |
| --- | --- |
| Thiếu **loại tài liệu** hoặc **nội dung nguồn** | Hỏi ngay — không bắt đầu soạn |
| Thiếu template / format cụ thể | Áp dụng structure chuẩn, ghi chú cuối tài liệu |
| Thiếu đối tượng đọc | Mặc định: nội bộ, mid-level |
| Thiếu deadline hoặc yêu cầu đặc biệt | Tiếp tục soạn, hỏi ở lượt sau nếu cần |

## Output Format bắt buộc

Mọi tài liệu soạn xong phải có format:

```
[NỘI DUNG TÀI LIỆU ĐẦY ĐỦ]

---
📋 THÔNG TIN CẦN BỔ SUNG:
- [NEEDS INPUT: ...] — lý do cần
- [VERIFY: ...] — lý do cần xác nhận

💡 GỢI Ý CẢI THIỆN (nếu có):
- [Chỉ ghi nếu liên quan trực tiếp đến chất lượng tài liệu]
```

## Ngôn ngữ

- Mặc định: **Tiếng Việt** — tất cả tài liệu soạn bằng tiếng Việt trừ khi yêu cầu khác
- Chuyển sang tiếng Anh chỉ khi user yêu cầu rõ ràng
- Thuật ngữ kỹ thuật quốc tế giữ nguyên tiếng Anh (CVSS, MITRE ATT&CK, CVE, SLA)
- Lần đầu dùng thuật ngữ → giải thích: "RBAC (Role-Based Access Control — Kiểm soát truy cập theo vai trò)"

## Document Control Header

Mọi tài liệu chính thức phải có header:

```
| Field | Value |
| --- | --- |
| **Tên tài liệu** | [Tên] |
| **Mã tài liệu** | [NEEDS INPUT: mã tài liệu theo quy ước tổ chức] |
| **Phiên bản** | [x.y] |
| **Phân loại** | [PUBLIC / INTERNAL / CONFIDENTIAL / RESTRICTED] |
| **Người soạn** | [Tên] |
| **Người phê duyệt** | [NEEDS INPUT: người phê duyệt] |
| **Ngày hiệu lực** | [NEEDS INPUT: ngày] |
| **Ngày rà soát tiếp theo** | [NEEDS INPUT: ngày] |
```
