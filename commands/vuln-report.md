# /vuln-report — Phân tích kết quả scan và tạo báo cáo vulnerability

Bạn đang phân tích kết quả vulnerability scan.

1. Hỏi người dùng:
   - Cung cấp scan results (file CSV/JSON/XML, hoặc paste trực tiếp)
   - Scanner nào (Nessus, Qualys, OpenVAS, Burp, Trivy, npm audit, khác)
   - Scope: internal / external / web app / container / cloud

2. Sử dụng **vuln-manager** agent.

3. Phân tích và tạo:
   - Deduplicated findings với false positive filtering
   - Risk-based prioritization (P1-P5) sử dụng SSVC, không chỉ CVSS
   - Remediation tracker table
   - Executive dashboard metrics
   - CVE deep-dive cho top 5 critical findings
   - SLA compliance check

4. Nếu có CVE cụ thể cần phân tích sâu, sử dụng CVE Analysis Template.
