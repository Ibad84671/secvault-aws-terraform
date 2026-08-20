#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

command -v terraform >/dev/null || { echo "Terraform is required."; exit 1; }

echo "==> Terraform format check"
terraform fmt -check -recursive

echo "==> Terraform init (backend disabled)"
terraform init -backend=false

echo "==> Terraform validate"
terraform validate

echo "==> Validation complete"
