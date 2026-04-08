---
name: compliance-frameworks
description: >
  Reference material for cybersecurity compliance frameworks and Vietnamese regulations.
  Use when mapping controls, conducting gap analysis, preparing for audits, writing
  policies aligned to frameworks, or checking regulatory compliance. Covers ISO 27001,
  NIST CSF, CIS Controls, PCI-DSS, and Vietnamese cybersecurity regulations.
  Always use when grc-advisor agent is active or when user mentions compliance,
  audit, framework, ISO, NIST, or Vietnamese regulations.
---

# Compliance Frameworks Reference

## Vietnamese Cybersecurity Regulations

### Luật An ninh mạng 2018 (Law 24/2018/QH14)
**Effective**: 01/01/2019
**Key Requirements**:
- Bảo vệ an ninh mạng cho hệ thống thông tin quan trọng quốc gia
- Data localization: Lưu trữ dữ liệu tại Việt Nam cho một số trường hợp
- Xác thực danh tính người dùng trên nền tảng số
- Hợp tác với cơ quan chức năng khi có yêu cầu
- Đánh giá an ninh mạng cho hệ thống thông tin quan trọng

### Nghị định 13/2023/NĐ-CP — Bảo vệ Dữ liệu Cá nhân
**Effective**: 01/07/2023 (Vietnam's PDPA)
**Key Requirements**:
- **Consent**: Thu thập DLCN phải có sự đồng ý rõ ràng của chủ thể
- **Data Subject Rights**: Quyền truy cập, chỉnh sửa, xóa, rút consent
- **DPO**: Bổ nhiệm Cán bộ bảo vệ dữ liệu cá nhân
- **DPIA**: Đánh giá tác động xử lý DLCN
- **Breach Notification**: 72 giờ thông báo cho Bộ Công an
- **Cross-border Transfer**: Hạn chế chuyển DLCN ra nước ngoài
- **Records**: Lưu trữ hồ sơ xử lý DLCN

### Nghị định 85/2016/NĐ-CP — An toàn thông tin theo cấp độ
**5 Security Levels**:
| Cấp | Đối tượng | Yêu cầu |
|-----|-----------|---------|
| 1 | Hệ thống nội bộ thông thường | Bảo vệ cơ bản |
| 2 | Hệ thống phục vụ hoạt động nội bộ | Bảo vệ tiêu chuẩn |
| 3 | Hệ thống phục vụ công dân/doanh nghiệp | Bảo vệ nâng cao |
| 4 | Hệ thống quan trọng quốc gia | Bảo vệ nghiêm ngặt |
| 5 | Hệ thống tối quan trọng | Bảo vệ tối đa |

### Thông tư 12/2022/TT-BTTTT
Chi tiết hóa yêu cầu đảm bảo ATTT cho từng cấp độ, bao gồm:
- Yêu cầu kiểm tra, đánh giá ATTT
- Giám sát an toàn thông tin
- Ứng cứu sự cố
- Kiểm tra, đánh giá định kỳ

## ISO/IEC 27001:2022 — Quick Reference

### Annex A Control Domains (93 controls in 4 themes):
1. **Organizational (37)**: Policies, roles, threat intel, asset management, access control, supplier relationships, incident management, compliance
2. **People (8)**: Screening, terms, awareness, disciplinary, termination, remote working, reporting
3. **Physical (14)**: Perimeters, entry, offices, monitoring, utilities, cabling, equipment, storage media, maintenance
4. **Technological (34)**: Endpoints, privileged access, access restriction, source code, authentication, capacity, malware, vulnerabilities, logging, network, web filtering, cryptography, SDLC, testing, change management, data masking, DLP, monitoring, redundancy

### Key New Controls in 2022:
- A.5.7 Threat intelligence
- A.5.23 Cloud services security
- A.5.30 ICT readiness for business continuity
- A.7.4 Physical security monitoring
- A.8.9 Configuration management
- A.8.10 Information deletion
- A.8.11 Data masking
- A.8.12 Data leakage prevention
- A.8.16 Monitoring activities
- A.8.23 Web filtering
- A.8.28 Secure coding

## NIST CSF 2.0 — Quick Reference

### 6 Functions:
1. **GOVERN (GV)**: Organizational context, risk management strategy, roles, policy, oversight, supply chain
2. **IDENTIFY (ID)**: Asset management, risk assessment, improvement
3. **PROTECT (PR)**: Identity management, awareness, data security, platform security, technology resilience
4. **DETECT (DE)**: Continuous monitoring, adverse event analysis
5. **RESPOND (RS)**: Incident management, analysis, mitigation, reporting, communication
6. **RECOVER (RC)**: Incident recovery plan execution, communication

## Cross-Framework Control Mapping (Top 20)

| Domain | ISO 27001:2022 | NIST CSF 2.0 | CIS v8 |
|--------|---------------|-------------|--------|
| Asset Inventory | A.5.9 | ID.AM-1,2 | CIS 1 |
| Access Control | A.5.15-18 | PR.AA-1-6 | CIS 5,6 |
| MFA | A.8.5 | PR.AA-3 | CIS 6.3,6.5 |
| Vulnerability Mgmt | A.8.8 | ID.RA-1 | CIS 7 |
| Audit Logging | A.8.15 | DE.CM-9 | CIS 8 |
| Email/Web Security | A.8.23 | PR.DS | CIS 9 |
| Malware Defense | A.8.7 | PR.PS | CIS 10 |
| Data Recovery | A.8.13 | RC.RP | CIS 11 |
| Network Security | A.8.20-22 | PR.DS | CIS 12,13 |
| Security Awareness | A.6.3 | PR.AT | CIS 14 |
| Incident Response | A.5.24-28 | RS.MA | CIS 17 |
| Penetration Testing | A.8.8 | ID.RA | CIS 18 |
