<H1>ДЗ день 8</H1>

Build custom nginx image



cd kubernetes-monitoring/nginx
docker build -t pa3mep/nginx:1.3 kubernetes-monitoring/nginx/
docker login --username pa3mep
docker push pa3mep/nginx:1.3

kubectl apply -f kubernetes-monitoring/nginx/nginx.yaml

kubectl delete -f kubernetes-monitoring/nginx/nginx.yaml


kubectl apply -f kubernetes-monitoring/prometheus.yaml

kubectl delete -f kubernetes-monitoring/prometheus.yaml


kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

kubectl apply -f kubernetes-monitoring/ServiceMonitor.yaml

kubectl delete -f kubernetes-monitoring/ServiceMonitor.yaml