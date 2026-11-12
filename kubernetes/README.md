Helm options for applying:
helm upgrade --install infra1 ./infra1_chart -f values.yaml

helm template ./infra1 -f values.yaml   # preview the rendered YAML without applying
helm uninstall infra1                     # delete everything in one go
helm rollback infra1 1                    # revert to a previous release



Order for kubectl apply:
kubectl apply -f Namespace.yaml
kubectl apply -f AppA.yaml
kubectl apply -f AppB.yaml
kubectl apply -f Nginx_Config.yaml
kubectl apply -f Nginx.yaml


destroy
kubectl delete -f Nginx.yaml
kubectl delete -f Nginx_Config.yaml
kubectl delete -f AppA.yaml
kubectl delete -f AppB.yaml
kubectl delete -f Namespace.yaml