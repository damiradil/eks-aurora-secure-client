# EKS + Aurora Secure PostgreSQL Client (Terraform)

Run a secure PostgreSQL client on Amazon EKS that reads creds from AWS Secrets Manager and connects to Aurora PostgreSQL (Serverless v2) over TLS.

## Prereqs
AWS account + IAM perms to create VPC/EKS/RDS/IAM/Secrets.
CLI tools: terraform, aws, kubectl.
Terraform backend: update backend.tf with your own S3 bucket
AWS CLI logged in (e.g., aws configure).

## Quick start
### 1) clone and enter repo
git clone repo link
cd to repo folder

### 2) set your inputs
cp terraform.tfvars.example terraform.tfvars
edit terraform.tfvars with your values (eks_public_access_cidrs)
tip: leave db_engine_version = null to avoid version drift

### 3) provision
terraform init
terraform apply

### 4) kubeconfig for kubectl
aws eks update-kubeconfig \
  --name $(terraform output -raw eks_cluster_name) \
  --region us-east-2 \
  --alias helium-eks-us-east-2

### 5) check CSI driver & provider
kubectl --context helium-eks-us-east-2 -n kube-system get pods | grep -E 'secrets-store|csi|provider'

### 6) verify client job output (SELECT now();)
kubectl --context helium-eks-us-east-2 -n db-client get pods -l app=db-client
POD=$(kubectl --context helium-eks-us-east-2 -n db-client get pods -l job-name=psql-now -o jsonpath='{.items[0].metadata.name}')
kubectl --context helium-eks-us-east-2 -n db-client logs "$POD"

Expected logs include a timestamp from SELECT now();.

## Rerun the client job
kubectl --context helium-eks-us-east-2 -n db-client delete job psql-now --ignore-not-found
terraform apply -target=module.db_client

## Tear down
terraform destroy

## Notes
Secrets are not stored in Kubernetes; they’re mounted at runtime via Secrets Store CSI using IRSA (least-priv).
The Job sets a TTL so completed runs auto-GC after a while (if enabled in the module).