k get namespaces
kubectl create -f admin/namespace-dev.json
helm install kittens . -n development --set "db.database_url=$(terraform -chdir="../infrastructure/live_ci" output  --raw database_url)"

kubectl config current-context
kubectl config use-context dev

helm uninstall kittens -n development
