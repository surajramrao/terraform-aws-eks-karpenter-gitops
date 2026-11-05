# `terraform-aws-eks-karpenter-gitops`

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.10.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-~%3E5.80.0-FF9900?logo=amazonaws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![IaC Security](https://img.shields.io/badge/Trivy_SARIF_%2B_TFLint-Gated-00C853?logo=githubactions)](./SECURITY.md)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](./LICENSE)

An enterprise-grade, security-hardened Open-Source Infrastructure-as-Code (IaC) blueprint for provisioning **Amazon EKS v1.32 clusters**, **Karpenter v1 Autoscaling with EKS Pod Identity**, and **Multi-AZ VPCs with Flow Logs**, structured around **directory-isolated environment root modules** (`environments/dev` and `environments/prod`) and native Terraform 1.10+ S3 state locking (`use_lockfile = true`).

---

## Enterprise 3-Workflow GitOps Pipeline Architecture

In enterprise platform engineering, **Trivy security scanning and static analysis act as a hard upstream gate** before any `terraform plan` or `terraform apply` is allowed to touch cloud state:

```text
[Pull Request Opened]
       │
       ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Workflow 01: .github/workflows/ci-validate-sec.yml                      │
│  ├── Job 1 (security-and-lint-gate): fmt + validate + TFLint + Trivy    │
│  │    └── Uploads Trivy SARIF report to GitHub Security Code Scanning   │
│  └── Job 2 (speculative-terraform-plan) [needs: security-and-lint-gate] │
│       └── Assumes AWS OIDC Role -> runs speculative `terraform plan`    │
│           and posts formatted diff + security badge to PR comment       │
└─────────────────────────────────────────────────────────────────────────┘
       │ (PR Approved & Merged to `main`)
       ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Workflow 02: .github/workflows/cd-terraform-main.yml                    │
│  ├── Stage 1 (pre-deploy-security-gate): Re-verifies Trivy & TFLint     │
│  ├── Stage 2 (deploy-dev) [needs: pre-deploy-security-gate]             │
│  │    └── Runs `terraform plan -out=dev.tfplan` & `apply` in `dev`      │
│  └── Stage 3 (deploy-prod) [needs: deploy-dev, environment: production] │
│       └── Pauses for Manual Platform Reviewer Approval Gate ->          │
│           Runs `terraform plan -out=prod.tfplan` & `apply` in `prod`    │
└─────────────────────────────────────────────────────────────────────────┘
       │ (Weekdays at 06:00 UTC)
       ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Workflow 03: .github/workflows/scheduled-drift-audit.yml                │
│  └── Runs `terraform plan -detailed-exitcode` across `dev` & `prod`     │
│      and opens a `[DRIFT DETECTED]` GitHub Issue if exitcode == 2       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```text
terraform-aws-eks-karpenter-gitops/
├── .github/
│   └── workflows/
│       ├── ci-validate-sec.yml          # 01: PR Gate (Validate, TFLint, Trivy SARIF -> Gated Plan)
│       ├── cd-terraform-main.yml        # 02: Main CD (Trivy Gate -> Apply Dev -> Approval -> Apply Prod)
│       └── scheduled-drift-audit.yml    # 03: Scheduled Weekday Drift Detection -> GitHub Issue Alert
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── eks-karpenter/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── backend.tf                   # Hardcoded Dev S3 bucket + Dev KMS lock (use_lockfile = true)
│   │   ├── providers.tf                 # Hardcoded Dev Account IAM assume_role
│   │   ├── main.tf                      # Calls ../../modules/vpc & eks-karpenter
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars             # Auto-loaded by Terraform in environments/dev
│   └── prod/
│       ├── backend.tf                   # Hardcoded Prod S3 bucket + Prod KMS lock (use_lockfile = true)
│       ├── providers.tf                 # Hardcoded Prod Account IAM assume_role
│       ├── main.tf                      # Calls ../../modules/vpc & eks-karpenter
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars             # Auto-loaded by Terraform in environments/prod
├── .gitignore
├── .tflint.hcl                          # Enforces unused variable & local module call inspection
├── .trivyignore                         # Documented security exceptions
├── SECURITY.md
├── LICENSE
└── README.md
```

---

## Deterministic Local Usage (Zero CLI Flags)

```bash
# Plan or deploy Development
cd environments/dev
terraform init
terraform plan

# Plan or deploy Production
cd environments/prod
terraform init
terraform plan
```

---

## License

Licensed under the **Apache License 2.0**. See [`LICENSE`](./LICENSE) for details.
# terraform-aws-eks-karpenter-gitops
