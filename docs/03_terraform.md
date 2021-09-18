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
terraform -chdir=ops/infrastructure apply -auto-approve
terraform -chdir=ops/infrastructure apply -auto-approve -replace=aws_instance.dogs_server
```

Connect:
```
ssh -i ~/.ssh/aws_key "ec2-user@$(terraform output -raw public_ip)"
curl "ec2-user@$(terraform -chdir=ops/infrastructure output -raw public_ip)"
curl "ec2-user@$(terraform output -raw public_ip)/kittens/info"
curl "ec2-user@$(terraform output -raw dns_name)/kittens/info"
```
terraform fmt
terraform output db_connection_uri
terraform validate

https://github.com/terraform-aws-modules/terraform-aws-rds/blob/master/examples/complete-postgres/outputs.tf
