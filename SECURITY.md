# Security Policy & Enterprise Hardening Architecture

## Supported Versions

| Release Branch | Terraform Version | AWS Provider | EKS Version | Security Support |
| :--- | :--- | :--- | :--- | :--- |
| `main` (`v2.x`) | `>= 1.10.0` | `>= 5.80.0` | `1.32` | Active |

## Enterprise Security Controls Enforced in This Repository

1. **Directory-Isolated State Backends & Native S3 Lockfiles (`use_lockfile = true`):**
   - `environments/dev` and `environments/prod` are completely independent Terraform root modules with hardcoded S3 buckets, KMS encryption keys (`alias/terraform-state-lock-dev` / `prod`), and native Terraform 1.10+ S3 state locking (`use_lockfile = true`), eliminating CLI `-backend-config` human error and cross-environment blast radius.
2. **Strict Account Isolation via IAM `assume_role`:**
   - Each environment's `providers.tf` explicitly assumes an account-scoped execution role (`arn:aws:iam::111111111111:role/TerraformExecutionRole-Dev` vs. `arn:aws:iam::222222222222:role/TerraformExecutionRole-Prod`).
3. **Zero Implicit Cluster-Admin & Locked-Down EKS API Endpoint:**
   - `enable_cluster_creator_admin_permissions = false` disables implicit permanent admin rights. RBAC is declaratively governed via AWS EKS Access Entries (`API_AND_CONFIG_MAP`).
   - `cluster_endpoint_private_access = true` is enforced everywhere; `prod` disables public API access completely (`cluster_endpoint_public_access = false`), while `dev` restricts public access to an explicit corporate VPN `/32` CIDR (`203.0.113.50/32`), preventing Trivy `AVD-AWS-0040` (`0.0.0.0/0` exposure).
4. **Compute & Secret Hardening (IMDSv2, Encrypted GP3, KMS Secrets, EKS Pod Identity):**
   - Managed Node Groups enforce IMDSv2 (`http_tokens = "required"`, `http_put_response_hop_limit = 1`) and encrypted `gp3` root EBS volumes.
   - Kubernetes `secrets` are envelope-encrypted with a dedicated customer-managed AWS KMS key and all 5 EKS control plane audit logs (`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`) are enabled.
   - Karpenter uses **EKS Pod Identity** (`enable_pod_identity = true`) and SSE-encrypted SQS spot interruption queues.
5. **3-Stage Gated Enterprise CI/CD Pipeline:**
   - **Workflow 01 (`ci-validate-sec.yml`):** Runs `terraform fmt`, `validate`, `tflint`, and `trivy` (uploading SARIF reports to the GitHub Security tab), then gates a speculative `terraform plan` behind `needs: [security-and-lint-gate]`.
   - **Workflow 02 (`cd-terraform-main.yml`):** Re-verifies the Trivy/TFLint security gate on `main`, automatically plans and applies `environments/dev`, and pauses at the GitHub `production` Environment approval gate before applying `environments/prod`.
   - **Workflow 03 (`scheduled-drift-audit.yml`):** Runs weekday `terraform plan -detailed-exitcode` checks and automatically creates a GitHub Issue if out-of-band console drift (`exitcode == 2`) is detected.
