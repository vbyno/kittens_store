Setup empty terraform project ops/infrastructure

variables.tf - Inputs for infrastructure
main.tf - File with all future infrastructure resources
output.tf - Print results of provisioned infrastructure
versions.tf - Specification of providers and versions of terraform. See below

```bash
cd ops/infrastructure
touch variables.tf main.tf output.tf versions.tf
terraform init
terraform apply
```

Add .terraform to .gitignore

Add and commit the rest of the new files
