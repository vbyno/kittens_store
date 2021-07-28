Setup empty terraform project ops/infrastructure

variables.tf - Inputs for infrastructure
main.tf - File with all future infrastructure resources
output.tf - Print results of provisioned infrastructure
versions.tf - Specification of providers and versions of terraform. See below

```bash
cd ops/infrastructure
touch variables.tf main.tf output.tf versions.tf
tfenv install
tfenv use
cd ops/infrastructure && terraform init && cd ../..
terraform -chdir=ops/infrastructure plan
terraform apply -var-file=local.tfvars
```

Add .terraform to .gitignore

Add and commit the rest of the new files

Apply env variables
```
export $(cat ../../.env | xargs)
```

Console:
```
terraform -chdir=ops/infrastructure console
```
