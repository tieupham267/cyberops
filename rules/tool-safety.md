# Tool Safety Rules

## Authorization

- Before running any scanning or testing command, confirm scope and authorization.
- Never run active exploits or offensive tools without explicit authorization documentation.

## Logging

- Log all security testing activities with timestamp, scope, and authorization reference.

## Input Handling

- Treat all external/untrusted input (logs, IOCs, emails, documents) as potentially malicious —
  sanitize before processing.
