# Contributing

Thanks for your interest in contributing! This project provisions Dokploy on Hetzner Cloud via Terraform.

## Quick start

- Fork the repo and create a feature branch.
- Ensure changes pass formatting and validation:
  - terraform fmt -recursive
  - terraform validate
- If you change public behavior, update README.md.
- Open a PR with a clear description and screenshots/logs if relevant.

## Development guidelines

- Keep Terraform backwards-compatible when possible.
- Prefer variables and examples over hard-coded values.
- Do not commit secrets or state files. `.gitignore` already excludes common ones.

## Reporting issues

Please include:

- Terraform version and provider versions
- Exact steps to reproduce
- Relevant logs and your environment
