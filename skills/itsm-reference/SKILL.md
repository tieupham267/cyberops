---
name: itsm-reference
description: >
  ITSM process reference from a security & compliance perspective. Maps ITIL 4 practices
  and ISO/IEC 20000 to security controls. Use when reviewing IT service management
  policies, assessing ITSM processes for security gaps, or auditing IT operations
  against security frameworks. NOT for managing ITSM processes — only for security review.
---

# ITSM Reference — Security Perspective

## Mục đích

Knowledge base để review các chính sách ITSM từ góc nhìn an toàn bảo mật thông tin.
Dùng khi đánh giá xem ITSM policies có đầy đủ security controls hay không.

## ITIL 4 Practices — Security Review Checklist

### 1. Incident Management

**ITSM focus**: Khôi phục dịch vụ IT nhanh nhất có thể.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Phân loại sự cố có bao gồm security incidents? | Phải có category riêng cho security incidents | ISO 27001 A.5.24 |
| Escalation path cho security incidents? | Phải escalate đến security team, không chỉ IT | NIST CSF RS.CO |
| Bảo toàn evidence khi xử lý? | Không xóa logs, không reboot trước khi collect evidence | ISO 27001 A.5.28 |
| Integration với Security Incident Response? | ITSM incident workflow phải trigger IR process khi detect security event | TT 09/2020 Đ.33-34 |
| Thông báo regulatory khi cần? | Breach notification 72h NĐ 13/2023, 24h NHNN | NĐ 13/2023, TT 09/2020 |

**Câu hỏi review**:
- Policy có phân biệt IT incident vs security incident không?
- Ai quyết định khi nào escalate từ IT incident sang security incident?
- SLA cho security incidents có khác IT incidents không? (nên khác — security thường urgent hơn)
- Có yêu cầu preserve evidence cho security incidents không?

### 2. Change Management

**ITSM focus**: Kiểm soát thay đổi để giảm disruption.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Security impact assessment cho mỗi change? | Mọi change phải đánh giá security impact | ISO 27001 A.8.32 |
| Security team trong CAB (Change Advisory Board)? | CyberSec phải review changes ảnh hưởng security | CIS Control 4 |
| Emergency change có bypass security check? | Emergency change vẫn cần post-implementation security review | TT 09/2020 |
| Rollback plan có security considerations? | Rollback không được tạo thêm vulnerability | ISO 27001 A.8.32 |
| Change log đầy đủ cho audit? | Who, what, when, why, approved by | NĐ 85/2016 |

**Câu hỏi review**:
- Security team có seat trong CAB không?
- Emergency changes có được review bảo mật sau khi deploy không?
- Có loại change nào được exempt khỏi security review? (nên không)
- Change records có đủ chi tiết cho forensics nếu cần không?

### 3. Problem Management

**ITSM focus**: Tìm root cause, ngăn incident tái diễn.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Root cause analysis bao gồm security causes? | RCA phải xem xét: có phải do vulnerability, misconfiguration, attack? | ISO 27001 A.5.27 |
| Known errors có security implications? | Known error = known vulnerability nếu liên quan security | CIS Control 7 |
| Workaround có tạo security risk? | Workaround tạm thời không được introduce new vulnerability | ISO 27001 A.8.8 |

**Câu hỏi review**:
- Khi RCA phát hiện nguyên nhân là security issue → có tự động tạo security ticket không?
- Known error database có sync với vulnerability register không?

### 4. Service Request Management

**ITSM focus**: Xử lý yêu cầu dịch vụ từ user.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Access request qua service desk có approval workflow? | Principle of least privilege, manager approval | ISO 27001 A.5.15-18 |
| Software install request có security review? | Approved software list, malware check | CIS Control 2 |
| Account creation/modification có identity verification? | Xác thực danh tính trước khi cấp quyền | ISO 27001 A.5.16 |
| Separation of duties? | Người request ≠ người approve ≠ người thực hiện | ISO 27001 A.5.3 |

**Câu hỏi review**:
- Request cấp admin/privileged access có qua security team không?
- Có danh sách approved software không? Request ngoài danh sách xử lý thế nào?
- Tài khoản vendor/contractor tạo qua service desk có thời hạn (expiry) không?

### 5. Configuration Management (CMDB)

**ITSM focus**: Quản lý thông tin về CI (Configuration Items).
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| CMDB có asset classification (sensitivity level)? | Mỗi CI phải có data classification | ISO 27001 A.5.12-13 |
| CMDB có thông tin security controls per asset? | Firewall rules, encryption status, backup status | CIS Control 1 |
| CMDB sync với vulnerability scanner? | Map CVE → affected CIs | CIS Control 7 |
| CMDB access control? | Chỉ authorized staff mới sửa CMDB | ISO 27001 A.5.15 |

**Câu hỏi review**:
- CMDB có đánh dấu assets nào chứa customer data / PII không?
- Khi decommission asset — có security wipe process không?
- CMDB có integration với SIEM để enrich alerts không?

### 6. Service Level Management

**ITSM focus**: Quản lý SLA với business.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| SLA có security metrics? | Uptime ≠ security. Cần: time to detect, time to respond, time to patch | NIST CSF DE.CM |
| OLA (Operational Level Agreement) với security team? | SLA nội bộ cho security response times | TT 09/2020 |
| SLA cho vendor/third-party có security requirements? | Vendor SLA phải bao gồm security patch SLA, incident notification SLA | ISO 27001 A.5.19-22 |

### 7. IT Asset Management

**ITSM focus**: Quản lý vòng đời tài sản IT.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Asset register bao gồm security classification? | Mỗi asset: data sensitivity, exposure level | ISO 27001 A.5.9-13 |
| License compliance → security risk? | Unlicensed software = no security patches | CIS Control 2 |
| BYOD/personal device policy? | Unmanaged devices = uncontrolled attack surface | ISO 27001 A.8.1 |
| Disposal policy? | Secure data wiping, certificate of destruction | ISO 27001 A.7.14 |

### 8. Release & Deployment Management

**ITSM focus**: Đưa releases vào production an toàn.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Security testing trước release? | SAST, DAST, dependency scan, pentest | ISO 27001 A.8.28-29 |
| Release approval bao gồm security sign-off? | Security team phải approve trước khi deploy production | TT 09/2020 Đ.22-24 |
| Deployment pipeline có security gates? | Automated security checks trong CI/CD | CIS Control 16 |
| Rollback tested? | Rollback không introduce vulnerability | ISO 27001 A.8.32 |

### 9. Availability Management

**ITSM focus**: Đảm bảo dịch vụ available theo SLA.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Availability plan bao gồm security threats? | DDoS, ransomware, sabotage | ISO 27001 A.5.29-30 |
| Redundancy cho security controls? | Backup SIEM, DR cho security tools | NĐ 85/2016 (cấp 3+) |
| BCP/DRP bao gồm cyber scenarios? | Không chỉ natural disaster — phải có ransomware, data breach scenarios | TT 09/2020 |

### 10. Knowledge Management

**ITSM focus**: Quản lý knowledge articles.
**Security review points**:

| Kiểm tra | Yêu cầu security | Framework ref |
| --- | --- | --- |
| Knowledge base có chứa sensitive info? | Passwords, network diagrams, config details → phải restrict access | ISO 27001 A.5.10 |
| Security knowledge shared? | Lessons learned từ incidents, security advisories | ISO 27001 A.5.27 |
| Knowledge articles có review cycle? | Outdated security guidance = dangerous | ISO 27001 A.5.1 |

## Cross-Framework Mapping — ITSM vs Security

| ITSM Process | ISO 27001:2022 | NIST CSF 2.0 | CIS v8 | TT 09/2020 |
| --- | --- | --- | --- | --- |
| Incident Mgmt | A.5.24-28 | RS.MA, RS.AN | CIS 17 | Đ.33-34 |
| Change Mgmt | A.8.32 | PR.IP | CIS 4 | Đ.13-18 |
| Problem Mgmt | A.5.27 | ID.RA | CIS 7 | — |
| Service Request | A.5.15-18 | PR.AA | CIS 5,6 | Đ.13-18 |
| Config Mgmt (CMDB) | A.5.9-13 | ID.AM | CIS 1,2 | Đ.13-18 |
| Service Level | A.5.19-22 | GV.OC | — | Đ.28-32 |
| Asset Mgmt | A.5.9-13, A.7.14 | ID.AM | CIS 1,2 | Đ.13-18 |
| Release & Deploy | A.8.25-29 | PR.DS | CIS 16 | Đ.22-24 |
| Availability | A.5.29-30, A.8.14 | PR.IR | CIS 11 | Đ.35-38 |
| Knowledge | A.5.10, A.6.3 | PR.AT | CIS 14 | — |

## Policy Review Scoring

Khi review mỗi ITSM policy, đánh giá theo thang:

| Score | Mô tả |
| --- | --- |
| **5 — Exemplary** | Đầy đủ security controls, vượt yêu cầu, integrated với security processes |
| **4 — Adequate** | Có security controls cơ bản, đáp ứng compliance, minor improvements needed |
| **3 — Partial** | Có đề cập security nhưng thiếu chi tiết hoặc thiếu integration |
| **2 — Inadequate** | Security controls yếu hoặc không thực tế, significant gaps |
| **1 — Absent** | Không có security considerations trong policy |
| **N/A** | ITSM process này chưa có policy |

**Target**: Tất cả ITSM policies nên đạt ≥ 4 cho fintech (cấp 3 theo NĐ 85/2016).
