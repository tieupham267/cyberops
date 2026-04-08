---
name: risk-assessment
description: >
  Risk assessment methodology, templates, and frameworks. Use when performing cyber risk 
  assessments, building risk registers, calculating risk scores, conducting BIA, 
  assessing third-party risk, or any risk management workflow. Always use when 
  risk-assessor agent is active or when user mentions "risk", "BIA", "risk register",
  "third-party assessment", or "risk treatment".
---

# Risk Assessment Skill

## Methodology Selection Guide

| Situation | Method | Reason |
|-----------|--------|--------|
| Quick assessment, limited data | Qualitative (5x5 matrix) | Fast, intuitive |
| Executive reporting, budget justification | Quantitative (FAIR) | Dollar amounts, defensible |
| Third-party vendor assessment | Questionnaire + rating | Standardized comparison |
| New system/project | Threat-based (STRIDE + risk) | Architecture-aligned |
| Compliance-driven | Control-based (gap analysis) | Maps to framework |

## FAIR (Factor Analysis of Information Risk) Quick Guide

### Step 1: Scope the Risk Scenario
"[Threat Agent] uses [Method] to [Effect] on [Asset] resulting in [Loss]"

Example: "External attacker uses phishing to steal credentials to customer database resulting in data breach of PII"

### Step 2: Estimate Loss Event Frequency (LEF)
- **Threat Event Frequency (TEF)**: How often does the threat agent act?
  - Contact frequency × Probability of action
- **Vulnerability (Vuln)**: If they act, how likely does it succeed?
  - Based on control strength vs. threat capability

LEF = TEF × Vulnerability

### Step 3: Estimate Loss Magnitude (LM)
**Primary Losses** (direct):
- Productivity loss (downtime × hourly cost × affected users)
- Response cost (IR team hours × rate)
- Replacement cost (rebuild/restore)

**Secondary Losses** (indirect):
- Regulatory fines
- Legal costs
- Reputation damage (customer churn)
- Competitive advantage loss

### Step 4: Calculate Risk
ALE (Annualized Loss Expectancy) = LEF × LM

Present as range: Optimistic (10th percentile) | Most Likely | Pessimistic (90th percentile)

## Third-Party Risk Assessment Questionnaire

### Tier Classification
| Tier | Criteria | Assessment Level |
|------|----------|-----------------|
| Critical | Access to PII/financial data, system integration, single point of failure | Full assessment + on-site + continuous monitoring |
| High | Access to internal data, API integration | Full questionnaire + evidence review |
| Medium | Limited data access, SaaS usage | Standard questionnaire |
| Low | No data access, replaceable | Minimal assessment |

### Assessment Domains (for questionnaire):
1. **Governance**: Security policy, org structure, CISO/DPO, certifications
2. **Access Control**: IAM, MFA, privileged access, access reviews
3. **Data Protection**: Encryption (transit + rest), DLP, data classification
4. **Network Security**: Segmentation, firewall, IDS/IPS, monitoring
5. **Application Security**: SDLC, code review, pen testing, vulnerability management
6. **Incident Response**: IR plan, IR team, notification procedures, SLA
7. **Business Continuity**: BCP/DRP, backup strategy, RTO/RPO, testing
8. **Compliance**: Relevant certifications (ISO 27001, SOC 2), regulatory compliance
9. **HR Security**: Background checks, security training, offboarding
10. **Physical Security**: Data center controls, office security

### Scoring
Each domain: 1 (Inadequate) → 2 (Needs Improvement) → 3 (Adequate) → 4 (Strong) → 5 (Exemplary)

**Overall Rating**:
- Average ≥ 4.0: Low Risk → Approve
- Average 3.0-3.9: Medium Risk → Approve with conditions
- Average 2.0-2.9: High Risk → Requires remediation plan
- Average < 2.0: Critical Risk → Do not proceed

## Business Impact Analysis (BIA)

### BIA Questionnaire per Business Process
```
Process Name: 
Process Owner:
Department:

1. Process Description:
   [What does this process do?]

2. Dependencies:
   - Applications/Systems: 
   - Data: 
   - Third Parties: 
   - Key Personnel: 

3. Impact Over Time:
   | Timeframe | Financial | Operational | Reputational | Legal | Score (1-5) |
   |-----------|-----------|-------------|--------------|-------|-------------|
   | 0-4 hours | | | | | |
   | 4-24 hours | | | | | |
   | 1-3 days | | | | | |
   | 3-7 days | | | | | |
   | 7+ days | | | | | |

4. Recovery Objectives:
   - RTO (Recovery Time Objective): 
   - RPO (Recovery Point Objective): 
   - MTPD (Maximum Tolerable Period of Disruption): 

5. Peak/Critical Periods:
   [Thời điểm nào process này đặc biệt quan trọng?]

6. Workarounds:
   [Có phương án thay thế tạm thời không?]
```

## Risk Treatment Decision Framework

```
                    High Impact
                        │
    ┌───────────────────┼───────────────────┐
    │                   │                   │
    │    TRANSFER       │     MITIGATE      │
    │  (Bảo hiểm,      │  (Implement       │
    │   outsource)      │   controls)       │
    │                   │                   │
────┼───────────────────┼───────────────────┼────
    │                   │                   │
    │    ACCEPT         │     AVOID         │
    │  (Document &      │  (Eliminate the   │
    │   monitor)        │   activity)       │
    │                   │                   │
    └───────────────────┼───────────────────┘
                        │
                    Low Impact
   Low Likelihood ──────┼────── High Likelihood
```
