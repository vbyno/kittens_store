```bash
k create -f postgres-configmap.yml && k create -f postgres-storage.yml && k create -f postgres-deployment.yml && k create -f postgres-service.yml && k create -f kittens-app-configmap.yml && k create -f kittens-app-deployment.yml && k create -f kittens-app-service.yml

kubectl get service postgres
psql -h localhost -U postgresadmin --password -p 31252 postgresdb

k delete -f kittens-app-service.yml && k delete -f kittens-app-deployment.yml && k delete -f kittens-app-configmap.yml && k delete -f postgres-service.yml && k delete -f postgres-deployment.yml && k delete -f postgres-storage.yml && k delete -f postgres-configmap.yml
```

Commands
```bash
k describe pod [name]
k logs [pod name]
k exec -it [pod name] -- bash
```

Debugging
https://learnk8s.io/troubleshooting-deployments
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
k get pv
minikube service --url kittens-app-service
```

# Helm
Installation https://helm.sh/docs/intro/quickstart/
```
brew install helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add matic https://matic-insurance.github.io/helm-charts
helm search repo bitnami
helm repo update

helm install bitnami/mysql --generate-name
helm list
helm uninstall mysql-1629562996

helm status happy-panda
helm show values bitnami/postgresql

helm install -f values.yaml bitnami/wordpress --generate-name

helm dependency update
helm install --dry-run --debug --values ./configs/values-production.yaml kittens .

helm install --dry-run kittens .
helm install kittens .
```

# EKS
```
aws eks list-clusters --region eu-west-3
aws eks --profile default --region eu-west-3 update-kubeconfig --name main_eks_cluster
k config get-contexts
k get pods -A
k get nodes
k get nodes -o wide
k describe pod kittens-app-deployment-7f...
k describe service kittens-app-loadbalancer
k get services
dig a9c91244416d5432799396cfa49a1c48-670824992.eu-west-3.elb.amazonaws.com
curl ac3a7ec573aee43ce978954513a0065f-826158688.eu-west-3.elb.amazonaws.com/kittens/info
```
