# aws-infra-baseline

A production-grade AWS network and IAM foundation, built entirely with Terraform and deployed
via GitHub Actions CI/CD.

I built a modular Terraform VPC foundation on AWS from scratch — VPC, public and private
subnets across multiple AZs, security group tiers, IAM roles, and a remote state backend
using S3 with Terraform's native state locking. The whole thing is deployed via GitHub Actions
with a plan-on-PR, apply-on-merge pipeline and a manual approval gate for production.
Downstream projects consume the VPC and subnet IDs via Terraform remote state — so the
network layer is a shared foundation, not duplicated config.

This repo provisions VPC, subnets, security groups, IAM (incl. SSM instance access), remote
state, ALB, EC2 smoke-test instances, and a single-AZ RDS instance — validated end-to-end with
a Flask app on EC2 querying RDS behind an ALB.

`outputs.tf` in `envs/dev` is a **contract** — anything reading this repo's state via
`terraform_remote_state` depends on those output names and types.

---

## Architecture

```
                         Internet
                             │
                             ▼
                    ┌─────────────────┐
                    │  Internet GW    │
                    └────────┬────────┘
                             │
   ┌─────────────────────────────────────────────────┐
   │                 Public subnets (2 AZs)           │
   │              ┌───────────────────┐               │
   │              │   ALB (:80)       │               │
   │              └─────────┬─────────┘               │
   │                        │  NAT Gateway             │
   └────────────────────────┼─────────────────────────┘
                             │
   ┌─────────────────────────────────────────────────┐
   │             Private app subnets (2 AZs)          │
   │        EC2 (Flask, SSM-attached, no key pairs)   │
   └────────────────────────┬─────────────────────────┘
                             │
   ┌─────────────────────────────────────────────────┐
   │             Private db subnets (2 AZs)           │
   │        RDS Postgres (db.t4g.micro, single-AZ)    │
   │              no NAT route — zero egress          │
   └───────────────────────────────────────────────────┘
```

Security groups chain SG-to-SG (`public_sg → private_app_sg → private_db_sg`) — no instance
is ever directly reachable from the internet. Access to private instances is via **AWS SSM
Session Manager** — no bastion host, no open port 22, no key pairs, sessions logged to
CloudWatch.

## Stack

| Layer          | Tool / Service                          |
|----------------|------------------------------------------|
| IaC            | Terraform ~> 1.15.6                      |
| Cloud          | AWS (`ca-central-1`)                     |
| CI/CD          | GitHub Actions                           |
| Auth (CI→AWS)  | OIDC — no long-lived AWS keys in GitHub  |
| Remote state   | S3, versioned + encrypted, native S3 locking (`use_lockfile`, no DynamoDB table) |

## Repo structure

```
aws-infra-baseline/
├── modules/
│   ├── vpc/            # VPC, subnets, IGW, NAT gateway, route tables, NACLs
│   ├── sg/              # Security group tiers: public, private-app, private-db
│   ├── iam/             # SSM instance role/profile, least-privilege policies
│   ├── remote-state/    # S3 state bucket (versioned, encrypted, native locking)
│   ├── ec2/              # Smoke-test EC2 instances (app tier), SSM-attached
│   ├── rds/              # Single-AZ, free-tier Postgres instance
│   └── alb/              # Internet-facing ALB, public tier's only entry point
│
├── envs/
│   └── dev/              # Environment root module — wires modules together, only env in use
│
└── .github/
    └── workflows/
        ├── terraform-plan.yml   # terraform fmt/validate/plan on every PR
        └── terraform-apply.yml  # terraform apply on merge to main (manual approval gate)
```

Each module is self-contained (`main.tf`, `variables.tf`, `outputs.tf`, `README.md`), takes no
environment-specific logic, and exposes every output a consumer might need. See each
module's README for its resources, inputs, and outputs (`terraform-docs`-generated).

## Key decisions

- **No bastion host.** SSM Session Manager only — the IAM instance role is attached directly
  to app-tier instances, no jump box, no inbound SSH.
- **No dedicated `envs/prod`.** Single-account, single-AZ portfolio project — `envs/dev` is
  the only environment root module in use; the environment folder concept is separate from
  git branching (`dev`/PRs → plan, `main` → apply).
- **RDS password via `manage_master_user_password`** (RDS-managed Secrets Manager secret) —
  no Terraform-generated secret ever touches state or user-data in plaintext.
- **ALB replaces direct-to-instance access.** The public tier's only entry point is the ALB;
  the app tier is reached exclusively via the ALB → private security group chain.

## Getting started

```bash
cd envs/dev
terraform init
terraform plan
```

Requires an AWS account with credentials configured (local: `AWS_PROFILE`; CI: OIDC role via
`AWS_ROLE_ARN` secret) and the S3 state bucket provisioned once via `modules/remote-state`
(see its README for bootstrapping order).
