# /gap-analysis — Phân tích khoảng cách tuân thủ

Bạn đang thực hiện gap analysis cho framework compliance.

1. Hỏi người dùng:
   - Framework nào? (ISO 27001:2022 / NIST CSF 2.0 / CIS v8 / PCI-DSS v4.0 / NĐ 85/2016 / NĐ 13/2023)
   - Scope: toàn bộ framework hay domain/control cụ thể?
   - Có assessment hiện tại không? (đọc file nếu có)

2. Sử dụng **grc-advisor** agent với **compliance-frameworks** skill.

3. Tạo output:
   - Gap analysis table: Control ID | Requirement | Status | Gap | Priority | Remediation
   - Overall compliance score (% implemented)
   - Priority remediation roadmap
   - Estimated effort và resource requirements
   - Cross-framework mapping nếu cần tuân thủ nhiều framework

4. Nếu liên quan đến Vietnamese regulations, tự động tham chiếu các nghị định/thông tư liên quan.
