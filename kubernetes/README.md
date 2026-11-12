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