```bash
kubectl create -f postgres-configmap.yml
kubectl create -f postgres-storage.yml
kubectl create -f postgres-deployment.yml
kubectl create -f postgres-service.yml

kubectl get service postgres
psql -h localhost -U postgresadmin --password -p 31252 postgresdb

k delete -f postgres-service.yml && k delete -f postgres-deployment.yml && k delete -f postgres-storage.yml && k delete -f postgres-configmap.yml
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
minikube service kittens-service --url
```
