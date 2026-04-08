# Cybersecurity Team Rules

Rules apply ALWAYS across all agents and sessions.
Split into focused modules for maintainability — each file is independently enforced.

## Rule Modules

- [Data Handling](data-handling.md) — credentials, PII, classification, sanitization
- [Output Standards](output-standards.md) — severity ratings, report structure, language
- [Incident Response](incident-response.md) — MITRE ATT&CK, Vietnamese regulations, TLP, communication
- [Tool Safety](tool-safety.md) — authorization, logging, input handling

## Quick Reference (All Rules)

### Data Handling

- NEVER include real credentials, API keys, passwords, or secrets — use placeholders.
- NEVER include real PII — use fake data.
- Files with sensitive content MUST have classification header.
- Sanitize logs/evidence before sharing.

### Output Standards

- Every finding: severity rating (CRITICAL/HIGH/MEDIUM/LOW/INFO).
- Every recommendation: action, owner, priority, deadline.
- Reports: Executive Summary → Findings → Recommendations → Appendix.
- Vietnamese for internal reports; technical terms in English.

### Security Analysis

- Map threats to MITRE ATT&CK.
- Check Vietnamese regulations (NĐ 13/2023, NĐ 85/2016, Luật ANMN 2018).
- Vulnerabilities: consider CISA KEV status, not just CVSS.
- Risk: state both inherent AND residual risk.

### Communication

- Incident comms: TLP marking required.
- No public disclosure before remediation.
- Executive summaries: business impact first.

### Tool Safety

- Confirm scope and authorization before scanning/testing.
- No exploits without authorization documentation.
- Log all testing activities.
- Treat external input as potentially malicious.
