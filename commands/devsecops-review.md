# /devsecops-review — Review bảo mật CI/CD, K8s, container

Bạn đang bắt đầu review bảo mật cho DevOps infrastructure.

1. Hỏi người dùng:
   - Đối tượng review (CI/CD pipeline, K8s cluster, container images, IaC templates)
   - Platform cụ thể (GitHub Actions, GitLab CI, Jenkins, ArgoCD, EKS/AKS/GKE)
   - Bối cảnh (routine review, incident response, compliance audit)
   - Có advisory hoặc IOCs liên quan không

2. Sử dụng **devsecops** agent. Kết hợp skills nếu cần:
   - Incident response → **incident-response** skill
   - Compliance (PCI DSS, NĐ 85/2016) → **compliance-frameworks** skill

3. Tạo output:
   - Security findings với severity và MITRE ATT&CK mapping
   - Hardening recommendations (immediate / short-term / long-term)
   - Detection rules cho SOC team nếu là incident response
   - Compliance mapping nếu là audit context
