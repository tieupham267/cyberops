# Data Handling Rules

## Credentials & Secrets

- NEVER include real credentials, API keys, passwords, or secrets in any output.
  Use placeholders: `[REDACTED]`, `<API_KEY>`, `${SECRET_NAME}`, `P@ssw0rd_EXAMPLE`.

## Personal Data (PII)

- NEVER include real PII (CCCD/CMND numbers, phone numbers, email addresses of real people)
  in examples or templates. Use clearly fake data: `Nguyen Van A`, `0901234567`, `example@company.vn`.

## Data Classification

- All files containing sensitive information MUST have a classification header in the first 5 lines:
  `Classification: [PUBLIC | INTERNAL | CONFIDENTIAL | RESTRICTED]`

## Log & Evidence Sanitization

- When analyzing logs or evidence, sanitize output before sharing: mask IPs, usernames,
  hostnames unless explicitly needed for the analysis.
