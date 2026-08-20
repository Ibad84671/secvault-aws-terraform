#!/usr/bin/env bash
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

read -r -p 'Type DESTROY to confirm Terraform destroy: ' confirmation
if [[ "$confirmation" != "DESTROY" ]]; then
  echo 'Destroy cancelled.'
  exit 1
fi

terraform init
terraform destroy -input=false
