# CST8918 A09 – Husky and GitHub Actions

## Student

**Name:** Ilyas Zazai  
**Course:** CST8918 – DevOps: Infrastructure as Code  
**Assignment:** A09 – Husky and GitHub Actions

## Project Overview

This project demonstrates how Terraform code can be checked locally before a Git commit and automatically checked again in GitHub when a pull request is created.

The project uses:

- Terraform for Azure infrastructure as code.
- Husky for a local Git pre-commit hook.
- TFLint for Terraform linting.
- GitHub Actions for pull-request validation.

## Workflow

```text
Write or modify Terraform code
             |
             v
       Run git commit
             |
             v
 Husky pre-commit hook runs
             |
             +--> terraform fmt -check
             +--> terraform validate
             +--> tflint
             |
       Pass or block commit
             |
             v
     Push feature branch
             |
             v
      Create pull request
             |
             v
 GitHub Actions checks Terraform
```

## Project Structure

```text
.
├── .github/
│   └── workflows/
│       └── action-terraform-verify.yml
├── .husky/
│   └── pre-commit
├── infrastructure/
│   ├── .terraform.lock.hcl
│   └── main.tf
├── .gitignore
├── package.json
├── package-lock.json
└── README.md
```

## Step 1 – Create the Terraform Configuration

The `infrastructure/main.tf` file defines the AzureRM provider and one Azure resource group.

```hcl
resource "azurerm_resource_group" "lab9" {
  name     = "rg-cst8918-a09-ilyas"
  location = "Canada Central"
}
```

This simple Azure resource was used to test Terraform formatting and validation. The assignment did not require deploying the resource with `terraform apply`.

## Step 2 – Initialize Terraform

Terraform was initialized inside the `infrastructure` directory:

```bash
terraform -chdir=infrastructure init -backend=false
```

This downloaded the AzureRM provider and created the Terraform dependency lock file.

## Step 3 – Install and Configure Husky

The Node project and Husky were initialized with:

```bash
npm init -y
npm install husky --save-dev
npx husky init
```

The `.husky/pre-commit` file runs:

```bash
terraform fmt -check -recursive
terraform -chdir=infrastructure validate
(cd infrastructure && tflint)
```

These commands run automatically before every normal Git commit.

## Step 4 – Test the Husky Pre-commit Hook

A Terraform formatting error was intentionally added to `main.tf`.

A normal commit was attempted:

```bash
git add .
git commit -m "test: verify Husky blocks incorrect Terraform formatting"
```

Husky detected the formatting problem and blocked the commit:

```text
infrastructure/main.tf
husky - pre-commit script failed
```

The formatting was then corrected:

```bash
terraform fmt -recursive
```

After the correction, the commit succeeded because formatting, validation, and linting passed.

## Step 5 – Configure GitHub Actions

The workflow is stored in:

```text
.github/workflows/action-terraform-verify.yml
```

It runs automatically for pull requests targeting `main` or `master`.

The workflow contains two jobs:

### Terraform Format Check

This job checks changed `.tf` files with:

```bash
terraform fmt -check
```

The job fails when a changed Terraform file does not use Terraform's standard formatting.

### Terraform Validate

This job initializes Terraform without a backend and validates the configuration:

```bash
terraform init -backend=false
terraform validate
```

The job detects Terraform syntax and configuration errors.

## Step 6 – Test the GitHub Actions Failure

A feature branch was created:

```bash
git switch -c test-github-actions
```

A formatting error was intentionally added to the Terraform resource declaration.

The commit used `--no-verify` to bypass the local Husky hook:

```bash
git commit --no-verify -m "test: trigger failed GitHub Actions formatting check"
```

After the branch was pushed and a pull request was created:

- The `terraform fmt check` job failed.
- The `terraform validate` job passed.

This proved that GitHub Actions detected incorrectly formatted Terraform code even though the local hook was bypassed.

## Step 7 – Correct the Error

The Terraform file was corrected with:

```bash
terraform fmt -recursive
```

The correction was committed normally:

```bash
git commit -m "fix: correct Terraform formatting"
git push
```

The normal commit also ran the Husky pre-commit checks successfully.

After the correction was pushed to the existing pull request, the GitHub Actions workflow ran again.

## Test Results

| Test | Expected result | Result |
|---|---|---|
| Husky with bad formatting | Commit blocked | Passed |
| Husky after formatting correction | Commit accepted | Passed |
| GitHub Actions with bad formatting | Format job failed | Passed |
| Terraform validation | Configuration valid | Passed |
| GitHub Actions after correction | Workflow passed | Passed |

## Key Learning

Husky provides a local quality gate before code is committed. GitHub Actions provides a second centralized quality gate during pull requests.

Using both tools means Terraform code is checked locally and checked again in the shared GitHub repository. The `--no-verify` test also demonstrates why CI validation is still necessary even when a local pre-commit hook exists.

## Pull Request Evidence

Pull request #1 contains the intentionally failing commit and the subsequent correction:

```text
https://github.com/Ilyzazai/cst8918-a09-husky-github-actions/pull/1
```
