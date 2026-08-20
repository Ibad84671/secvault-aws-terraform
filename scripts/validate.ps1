$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw 'Terraform is required.'
}

Write-Host '==> Terraform format check'
terraform fmt -check -recursive

Write-Host '==> Terraform init (backend disabled)'
terraform init -backend=false

Write-Host '==> Terraform validate'
terraform validate

Write-Host '==> Validation complete'
