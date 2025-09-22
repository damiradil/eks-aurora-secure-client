REPORT

Approach
I implemented the assignment using Terraform modules for VPC, EKS, Aurora PostgreSQL, EKS add-ons, IAM IRSA, and a secure db-client Job.
The client pod retrieves database credentials directly from AWS Secrets Manager via the Secrets Store CSI Driver and AWS Provider, using an IRSA role with least-privilege (secretsmanager:GetSecretValue + kms:Decrypt).
The pod then connects securely to Aurora over TLS and runs a test query (SELECT now();).

What Went Well
- Modular design: each resource group (vpc, eks, aurora, addons, irsa, db-client) is isolated and easy to extend.
- Security posture: no Kubernetes Secrets, credentials are mounted only at runtime, IRSA scoped tightly, Aurora encrypted at rest + TLS in transit.
- Cost-aware choices: Aurora Serverless v2 with low ACUs, minimal EKS node group, and a single NAT gateway.

Challenges & Solutions
- Helm ownership conflict: solved by splitting the CSI driver and AWS provider into separate Helm releases and disabling duplicate installs.
- Aurora version drift: AWS auto-upgrades minor versions; avoided “downgrade” errors by not pinning minor versions in Terraform.
- Secrets Manager name collision: resolved by adding a random suffix so secrets can be recreated without conflict.

Monitoring
For observability, I designed a hybrid monitoring stack that combines open-source flexibility with AWS-native durability:
- kube-prometheus-stack (Prometheus + Grafana): real-time Kubernetes metrics, flexible dashboards, and alerting.
- Fluentd → CloudWatch Logs: durable, centralized log storage with native AWS retention, alerting, and compliance features.
- Aurora Performance Insights: database query performance and wait event analysis unavailable from general-purpose tools.
This hybrid design is a good practice because it leverages each tool’s strengths: Prometheus for high-frequency cluster metrics, CloudWatch for long-term log durability and 
low operational overhead, and Aurora PI for deep database insights. It balances cost efficiency, flexibility, and operational simplicity, reflecting how production teams typically build observability.

Other Ideas
- Add Job TTL so completed jobs are auto-cleaned.
- Use sslmode=verify-full with the RDS CA bundle for stronger TLS validation.
- In real-world CI/CD, replace static AWS keys with GitHub OIDC to run Terraform securely.

Conclusion
The project demonstrates deploying a secure PostgreSQL client on EKS connected to Aurora, automated end-to-end with Terraform. 
The solution emphasizes modularity, security, cost-awareness, and extensibility, with a monitoring stack aligned to production best practices.