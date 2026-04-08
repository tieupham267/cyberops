---
name: security-maturity
description: >
  Security maturity models and roadmap planning reference. Covers SOC-CMM,
  NIST CSF Implementation Tiers, CIS Implementation Groups, and custom maturity
  scoring. Use when building security roadmaps, assessing current maturity,
  setting target state, or planning multi-phase security programs.
---

# Security Maturity — Roadmap Planning Reference

## 1. Maturity Models

### 1.1 NIST CSF Implementation Tiers

| Tier | Name | Mô tả | Typical org |
| --- | --- | --- | --- |
| **Tier 1** | Partial | Ad-hoc, reactive. Không có quy trình chính thức. Risk management không formalized | Startup, chưa có security team |
| **Tier 2** | Risk Informed | Có awareness về risk nhưng chưa org-wide policy. Một số quy trình documented | SMB có 1-2 security staff |
| **Tier 3** | Repeatable | Policy formalized, org-wide. Quy trình documented + repeatable. Regular review | Mid-size có security team |
| **Tier 4** | Adaptive | Continuous improvement. Threat-informed. Lessons learned feedback loop. Metrics-driven | Enterprise, mature SOC |

### 1.2 CIS Implementation Groups (IG)

| IG | Target | Controls | Typical org |
| --- | --- | --- | --- |
| **IG1** | Essential cyber hygiene | 56 safeguards | SMB, limited IT staff, basic security |
| **IG2** | Moderate complexity | 130 safeguards (IG1 + 74) | Mid-size, có security team, xử lý sensitive data |
| **IG3** | Advanced | 153 safeguards (IG1 + IG2 + 23) | Enterprise, mature security program, chống advanced threats |

**Áp dụng cho fintech VN**: Fintech payment ~100 nhân sự → target **IG2** minimum, hướng tới **IG3** cho systems xử lý payment data.

### 1.3 SOC Capability Maturity Model (SOC-CMM)

5 domains, mỗi domain scoring 0-5:

| Domain | Mô tả | Level 0-1 | Level 2-3 | Level 4-5 |
| --- | --- | --- | --- | --- |
| **Business** | Governance, compliance, reporting | Không có SOC charter | SOC charter, basic KPIs | Metrics-driven, continuous improvement |
| **People** | Staffing, skills, training | 1-2 người, no training plan | Defined roles, annual training | Career path, certifications, exercises |
| **Process** | Procedures, playbooks, workflows | Ad-hoc, undocumented | Documented SOPs, basic playbooks | Automated workflows, tested playbooks |
| **Technology** | Tools, integration, automation | Basic SIEM, no integration | SIEM + EDR + ticketing integrated | SOAR, threat intel platform, full visibility |
| **Services** | Monitoring, hunting, response | Reactive only, business hours | Proactive hunting, 8x5 monitoring | 24x7 monitoring, threat hunting program |

### 1.4 Generic Security Program Maturity (5 levels)

| Level | Name | Mô tả | Indicators |
| --- | --- | --- | --- |
| **1 — Initial** | Ad-hoc | Không có quy trình, reactive | Không có policies, không có security tools, incidents discovered by accident |
| **2 — Developing** | Basic controls | Có tools cơ bản, policies bắt đầu | Firewall + AV + basic SIEM, một số policies, manual processes |
| **3 — Defined** | Formalized | Quy trình documented, repeatable | SIEM + EDR + documented SOPs + regular vuln scan + annual risk assessment |
| **4 — Managed** | Measured | Metrics-driven, proactive | KPIs tracked, threat hunting, automation, regular pentest, compliance certified |
| **5 — Optimized** | Continuous improvement | Adaptive, threat-informed | Advanced analytics, red team, zero trust, threat intel integrated, continuous optimization |

## 2. Maturity Assessment Template

### Self-Assessment Scorecard

```
## Security Maturity Assessment: [Tên tổ chức]
## Date: [date]

### Domain Scores (1-5)

| Domain | Current | Target | Gap | Priority |
| --- | --- | --- | --- | --- |
| Governance & Strategy | | | | |
| Risk Management | | | | |
| Asset Management | | | | |
| Identity & Access Management | | | | |
| Data Protection | | | | |
| Network Security | | | | |
| Endpoint Security | | | | |
| Application Security | | | | |
| Security Operations (SOC) | | | | |
| Incident Response | | | | |
| Vulnerability Management | | | | |
| Awareness & Training | | | | |
| Third-party Risk | | | | |
| Business Continuity | | | | |
| Compliance | | | | |

### Overall Maturity: [X/5] → Target: [Y/5]

### Maturity Profile
- NIST CSF Tier: [1-4]
- CIS Implementation Group: [IG1/IG2/IG3]
- SOC-CMM Average: [X/5]
```

### Scoring Guide (cho mỗi domain)

| Score | Criteria |
| --- | --- |
| 1 | Không có hoặc ad-hoc. Không documented. Không assigned owner |
| 2 | Một phần. Có tool/policy cơ bản nhưng không consistent. Chưa measured |
| 3 | Defined + documented. Repeatable. Owner assigned. Reviewed periodically |
| 4 | Managed + measured. KPIs tracked. Proactive. Regular testing |
| 5 | Optimized. Continuous improvement. Automated. Threat-informed. Industry-leading |

## 3. Roadmap Planning Framework

### Phase Template

```
## Security Roadmap: [Tên tổ chức]
## Period: [start] → [end]
## Current maturity: [X/5] → Target maturity: [Y/5]

### Phase 1: Foundation (tháng 1-3)
- Focus: [domain gaps priority CRITICAL]
- Budget: [NEEDS INPUT]
- Headcount: [NEEDS INPUT]
- Key deliverables:
  1. [deliverable + owner + deadline]
  2. ...
- Success criteria: [measurable]
- Maturity target end of phase: [X/5]

### Phase 2: Build (tháng 4-6)
...

### Phase 3: Optimize (tháng 7-12)
...
```

### Roadmap Categories

Mỗi roadmap nên cover:

| Category | Ví dụ items |
| --- | --- |
| **People** | Hire, train, certify, define roles, build career path |
| **Process** | Write policies, SOPs, playbooks, implement frameworks |
| **Technology** | Deploy/upgrade tools, integrate, automate |
| **Governance** | Risk assessment, compliance, audit, reporting |

### Prioritization Matrix

Xếp items vào roadmap phases theo:

| | High Impact | Low Impact |
| --- | --- | --- |
| **Low Effort** | **Phase 1 — Quick wins** | Phase 2 — Nice to have |
| **High Effort** | **Phase 2 — Strategic** | Phase 3 hoặc Backlog |

Thêm ưu tiên bổ sung:
- Regulatory deadline (NĐ 13/2023 → bắt buộc tuân thủ)
- Risk level (CRITICAL/HIGH gaps trước)
- Dependencies (tool X cần trước khi implement Y)

## 4. SOC Roadmap Specifics

### SOC Maturity Phases (typical cho SMB fintech VN)

| Phase | Timeline | Focus | Target |
| --- | --- | --- | --- |
| **Phase 0: Current** | Now | Assess current state | Baseline score |
| **Phase 1: Foundation** | Tháng 1-3 | SIEM tuning, basic SOPs, alert triage process, FP reduction | SOC-CMM 2.0 |
| **Phase 2: Standardize** | Tháng 4-6 | Documented playbooks, detection rules library, threat hunting basics, KPIs | SOC-CMM 2.5 |
| **Phase 3: Automate** | Tháng 7-12 | SOAR integration, automated triage, enrichment pipeline, case management | SOC-CMM 3.0 |
| **Phase 4: Optimize** | Year 2 | Threat intel integration, advanced hunting, metrics-driven improvement, purple team | SOC-CMM 3.5-4.0 |

### SOC Roadmap Deliverables Checklist

**Phase 1 — Foundation**:
- [ ] SIEM rule tuning (reduce FP < 30%)
- [ ] Alert triage SOP documented
- [ ] Incident escalation process defined
- [ ] Log sources inventory complete
- [ ] Baseline metrics measured (alert volume, FP rate, MTTR)

**Phase 2 — Standardize**:
- [ ] Detection rules library (≥20 use cases)
- [ ] Playbooks for top 5 alert types
- [ ] Threat hunting quarterly cadence
- [ ] SOC KPI dashboard live
- [ ] Vulnerability management process integrated

**Phase 3 — Automate**:
- [ ] SOAR platform deployed (Shuffle/equivalent)
- [ ] Automated IOC enrichment
- [ ] Automated triage for top 3 alert types
- [ ] Case management (TheHive/equivalent) operational
- [ ] Integration: SIEM ↔ EDR ↔ SOAR ↔ Case Mgmt

**Phase 4 — Optimize**:
- [ ] Threat intel feeds integrated
- [ ] Proactive threat hunting monthly
- [ ] MITRE ATT&CK coverage map maintained
- [ ] Purple team exercise annually
- [ ] Continuous improvement loop documented

## 5. Budget Planning Reference

### Cost Categories cho security roadmap

| Category | Items | Estimation method |
| --- | --- | --- |
| **People** | Salary, training, certifications, hiring | Headcount × annual cost |
| **Technology** | License, subscription, infrastructure | Vendor quotes + growth factor |
| **Services** | MSSP, pentest, audit, consulting | Vendor quotes |
| **Process** | Policy development, compliance certification | Internal effort + external consulting |

### Typical allocation (SMB fintech VN)

| Category | % of security budget | Notes |
| --- | --- | --- |
| People | 40-50% | Salary là chi phí lớn nhất |
| Technology | 25-35% | Tools + infrastructure |
| Services | 10-20% | Pentest, audit, consulting |
| Process | 5-10% | Training, certification |

## 6. Vietnamese Regulatory Milestones

Khi xây roadmap cho fintech VN, include regulatory deadlines:

| Regulation | Yêu cầu | Deadline/Cadence | Phase |
| --- | --- | --- | --- |
| NĐ 13/2023 | DPIA, DPO, breach notification 72h | Phải tuân thủ ngay (đã hiệu lực) | Phase 1 |
| NĐ 85/2016 | Phân loại cấp độ ATTT | Phải tuân thủ ngay | Phase 1 |
| TT 09/2020 | Risk assessment hàng năm, BCP/DRP drill | Annual | Phase 1 (first), Phase 2+ (cadence) |
| TT 12/2022 | Yêu cầu kỹ thuật theo cấp độ (pentest, vuln scan, SIEM) | Ongoing | Phase 1-3 |
| ISO 27001 | Nếu target certification | 12-18 tháng preparation | Phase 2-3 |
| PCI DSS | Nếu xử lý card data | Ongoing + annual audit | Phase 1-3 |
