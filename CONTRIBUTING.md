# Contributing to SecVault

## Development workflow

1. Create a focused feature branch.
2. Make the smallest coherent Terraform/application change.
3. Run formatting and validation locally.
4. Run Checkov and Trivy for infrastructure changes.
5. Update documentation when architecture or security behavior changes.
6. Open a pull request against the primary branch.

## Required checks

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
checkov -d . --framework terraform
trivy config .
```

If a scanner reports a false positive or an intentional exception, document the reason next to the resource or in the scanner configuration. Never suppress findings simply to make CI green.

## Terraform guidelines

- Prefer `aws_iam_policy_document` over hand-written JSON policies.
- Keep permissions scoped to the resources actually required.
- Do not add credentials to variables, examples, user data, or tests.
- Keep module boundaries based on infrastructure responsibilities.
- Add descriptions and sensible validation to variables.
- Never apply destructive changes without reviewing the plan.

## Pull request expectations

A security-sensitive PR should explain:

- the threat or operational problem being addressed
- the AWS resources affected
- IAM/network implications
- cost implications
- validation performed
- any intentional residual risk
