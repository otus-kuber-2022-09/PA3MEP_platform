<H1>ДЗ день 9</H1>

<H2>Подготовка кластера</H2>

gcloud components update
gcloud container clusters get-credentials logging-cluster --zone europe-north1-a --project otus-367913

kubectl get nodes
NAME                                             STATUS   ROLES    AGE   VERSION
gke-logging-cluster-default-pool-21382edb-64vg   Ready    <none>   26m   v1.23.8-gke.1900
gke-logging-cluster-infra-pool-0a9d81e5-8c44     Ready    <none>   26m   v1.23.8-gke.1900
gke-logging-cluster-infra-pool-0a9d81e5-ls7c     Ready    <none>   26m   v1.23.8-gke.1900
gke-logging-cluster-infra-pool-0a9d81e5-vzvm     Ready    <none>   26m   v1.23.8-gke.1900

kubectl taint nodes gke-logging-cluster-infra-pool-0a9d81e5-vzvm gke-logging-cluster-infra-pool-0a9d81e5-ls7c gke-logging-cluster-infra-pool-0a9d81e5-8c44 node-role=infra:NoSchedule

<H2>Установка HipsterShop</H2>

kubectl create ns microservices-demo
kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Logging/microservices-demo-without-resources.yaml -n microservices-demo

kubectl get pods -n microservices-demo -o wide
NAME                                     READY   STATUS             RESTARTS        AGE     IP            NODE                                             NOMINATED NODE   READINESS GATES
adservice-548889999f-8gb6m               0/1     ImagePullBackOff   0               3m18s   10.104.0.15   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
cartservice-75cc479cdd-qvbwj             1/1     Running            1 (2m53s ago)   3m19s   10.104.0.4    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
checkoutservice-699758c6d9-ptsqg         1/1     Running            0               3m20s   10.104.0.8    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
currencyservice-7fc9cfc9cf-skhcp         1/1     Running            0               3m18s   10.104.0.11   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
emailservice-6c8d49f789-j9krf            1/1     Running            0               3m21s   10.104.0.10   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
frontend-5b8c8bf745-vlfsn                1/1     Running            0               3m20s   10.104.0.5    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
loadgenerator-799c7664dd-24rqv           1/1     Running            3 (118s ago)    3m18s   10.104.0.12   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
paymentservice-557f767677-sq87j          1/1     Running            0               3m19s   10.104.0.9    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
productcatalogservice-7b69d99c89-lwfcg   1/1     Running            0               3m19s   10.104.0.6    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
recommendationservice-7f78d66cc9-q7qnn   1/1     Running            0               3m20s   10.104.0.7    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
redis-cart-fd8d87cdb-xrnhb               1/1     Running            0               3m18s   10.104.0.14   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
shippingservice-64999cdc59-xfspd         1/1     Running            0               3m18s   10.104.0.13   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>


Похоже возникли проблемы с подом adservice. Попробуем поправить. Изменим версию на, к примеру, 0.3.4. И перезапустим.

wget https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Logging/microservices-demo-without-resources.yaml

kubectl apply -f microservices-demo-without-resources.yaml -n microservices-demo

Теперь всё хорошо.
NAME                                     READY   STATUS    RESTARTS      AGE   IP            NODE                                             NOMINATED NODE   READINESS GATES
adservice-64bddfd848-dcnbs               1/1     Running   0             57s   10.104.0.16   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
cartservice-75cc479cdd-qvbwj             1/1     Running   1 (20m ago)   20m   10.104.0.4    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
checkoutservice-699758c6d9-ptsqg         1/1     Running   0             20m   10.104.0.8    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
currencyservice-7fc9cfc9cf-skhcp         1/1     Running   0             20m   10.104.0.11   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
emailservice-6c8d49f789-j9krf            1/1     Running   0             20m   10.104.0.10   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
frontend-5b8c8bf745-vlfsn                1/1     Running   0             20m   10.104.0.5    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
loadgenerator-799c7664dd-24rqv           1/1     Running   3 (19m ago)   20m   10.104.0.12   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
paymentservice-557f767677-sq87j          1/1     Running   0             20m   10.104.0.9    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
productcatalogservice-7b69d99c89-lwfcg   1/1     Running   0             20m   10.104.0.6    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
recommendationservice-7f78d66cc9-q7qnn   1/1     Running   0             20m   10.104.0.7    gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
redis-cart-fd8d87cdb-xrnhb               1/1     Running   0             20m   10.104.0.14   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>
shippingservice-64999cdc59-xfspd         1/1     Running   0             20m   10.104.0.13   gke-logging-cluster-default-pool-21382edb-64vg   <none>           <none>

<H2>Установка EFK стека</H2>

helm repo add elastic https://helm.elastic.co
helm repo add fluent https://fluent.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update

kubectl create ns observability
helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability -f elasticsearch.values.yaml
helm upgrade --install kibana elastic/kibana --namespace observability
helm upgrade --install fluent-bit stable/fluent-bit --namespace observability  -f fluent-bit.values.yaml

<H2>Установка nginx-ingress</H2>

kubectl create ns nginx-ingress
helm upgrade --install  nginx-ingress ingress-nginx/ingress-nginx --wait --namespace=nginx-ingress --version=4.3.0 -f nginx-ingress.values.yaml

helm upgrade --install kibana elastic/kibana --namespace observability -f kibana.values.yaml

На счёт элегантного метода, ну не знаю, можно переименовать поля во что-нибудь другое. 

<H2>Мониторинг ElasticSearch</H2>

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm repo list
helm upgrade --install elasticsearch-exporter prometheus-community/prometheus-elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --namespace=observability -f prometheus-elasticsearch-exporter-values.yaml
Error: UPGRADE FAILED: resource mapping not found for name: "elasticsearch-exporter-prometheus-elasticsearch-exporter" namespace: "" from "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"
ensure CRDs are installed first


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace=observability

helm upgrade --install elasticsearch-exporter prometheus-community/prometheus-elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --namespace=observability -f prometheus-elasticsearch-exporter-values.yaml



helm upgrade --install elasticsearch-exporter stable/elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --set serviceMonitor.enabled=true --namespace=observability
