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