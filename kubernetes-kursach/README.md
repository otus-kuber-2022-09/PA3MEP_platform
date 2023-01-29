<H1>Курсовой проэкт</H1>

<H2>Первоначальный план</H2>
Запустить Хипстер Шоп на Кубернетесе
    Собрать образы Хипстер шопа
    Автоматически выложить образы на ДокерХаб
Запустить ХипстерШоп с помошью Flux
    Настроить кластер Кубернетеса
    Запустить istio
    Запустить Flux
Автоматически обновить ХипстерШоп до следующей версии

<H2>Запустить Хипстер Шоп на Кубернетесе</H2>
<H3>Собрать образы Хипстер шопа</H3>

Репозиторий: https://gitlab.com/otus43/microservices-demo/-/tree/main
CI Pipeline: https://gitlab.com/otus43/microservices-demo/-/pipelines

<H3>Автоматически выложить образы на ДокерХаб</H3>

Репозитории ДокерХаб: 

https://hub.docker.com/repository/docker/pa3mep/adservice<br>
https://hub.docker.com/repository/docker/pa3mep/frontend/general<br>
https://hub.docker.com/repository/docker/pa3mep/cartservice/general<br>
https://hub.docker.com/repository/docker/pa3mep/checkoutservice/general<br>
https://hub.docker.com/repository/docker/pa3mep/currencyservice/general<br>
https://hub.docker.com/repository/docker/pa3mep/emailservice/general<br>
https://hub.docker.com/repository/docker/pa3mep/loadgenerator/general<br>
https://hub.docker.com/repository/docker/pa3mep/paymentservice/general<br>
https://hub.docker.com/repository/docker/pa3mep/productcatalogservice/general<br>
https://hub.docker.com/repository/docker/pa3mep/recommendationservice/general<br>
https://hub.docker.com/repository/docker/pa3mep/shippingservice/general<br>

<H2>Запустить ХипстерШоп с помошью Flux</H2>
<H3>Настроить кластер Кубернетеса</H3>

Получившийся кластер выглядит сдедующим образом
<pre><code>
kubectl get nodes
NAME                                  STATUS   ROLES    AGE   VERSION
gke-otus-default-pool-61b1c61f-8sxv   Ready    <none>   29m   v1.24.8-gke.2000
gke-otus-default-pool-61b1c61f-s9nk   Ready    <none>   30m   v1.24.8-gke.2000
gke-otus-default-pool-61b1c61f-x20p   Ready    <none>   29m   v1.24.8-gke.2000
</pre></code>


<H3>Запустить istio</H3>

Сливаем последнюю версию istio
<pre><code>
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.16.1/bin
sudo mv istioctl /usr/bin
</pre></code>

Смотрим что получилось

<pre><code>
istioctl version
no running Istio pods in "istio-system"
1.16.1
</pre></code>

Устанавливаем профиль Демо
<pre><code>
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system
</pre></code>

Итого 

<pre><code>
kubectl get all -n istio-system
NAME                                        READY   STATUS    RESTARTS   AGE
NAME                                       READY   STATUS    RESTARTS   AGE
pod/grafana-96dd4774d-4v44n                1/1     Running   0          52s
pod/istio-egressgateway-688d4797cd-nfq65   1/1     Running   0          6m10s
pod/istio-ingressgateway-6bd9cfd8-h7l52    1/1     Running   0          6m10s
pod/istiod-68fdb87f7-48sqn                 1/1     Running   0          6m21s
pod/jaeger-5994d55ffc-q9rnl                1/1     Running   0          52s
pod/kiali-64df7bf7cc-vwqdh                 1/1     Running   0          50s
pod/prometheus-6549d6bdcc-8m5rf            2/2     Running   0          49s

NAME                           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                                                      AGE
service/grafana                ClusterIP      10.124.10.201   <none>          3000/TCP                                                                     53s
service/istio-egressgateway    ClusterIP      10.124.15.7     <none>          80/TCP,443/TCP                                                               6m9s
service/istio-ingressgateway   LoadBalancer   10.124.10.88    34.88.251.145   15021:32387/TCP,80:31241/TCP,443:32730/TCP,31400:30537/TCP,15443:30835/TCP   6m9s
service/istiod                 ClusterIP      10.124.4.135    <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP                                        6m21s
service/jaeger-collector       ClusterIP      10.124.10.118   <none>          14268/TCP,14250/TCP,9411/TCP                                                 51s
service/kiali                  ClusterIP      10.124.14.208   <none>          20001/TCP,9090/TCP                                                           50s
service/prometheus             ClusterIP      10.124.15.85    <none>          9090/TCP                                                                     49s
service/tracing                ClusterIP      10.124.3.113    <none>          80/TCP,16685/TCP                                                             51s
service/zipkin                 ClusterIP      10.124.8.27     <none>          9411/TCP                                                                     51s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana                1/1     1            1           52s
deployment.apps/istio-egressgateway    1/1     1            1           6m10s
deployment.apps/istio-ingressgateway   1/1     1            1           6m10s
deployment.apps/istiod                 1/1     1            1           6m21s
deployment.apps/jaeger                 1/1     1            1           52s
deployment.apps/kiali                  1/1     1            1           50s
deployment.apps/prometheus             1/1     1            1           49s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/grafana-96dd4774d                1         1         1       52s
replicaset.apps/istio-egressgateway-688d4797cd   1         1         1       6m10s
replicaset.apps/istio-ingressgateway-6bd9cfd8    1         1         1       6m10s
replicaset.apps/istiod-68fdb87f7                 1         1         1       6m21s
replicaset.apps/jaeger-5994d55ffc                1         1         1       52s
replicaset.apps/kiali-64df7bf7cc                 1         1         1       50s
replicaset.apps/prometheus-6549d6bdcc            1         1         1       49s
</pre></code>


Если запускать ту же конфигурацию на своём железе, то придётся установить MetalLB и добавить роут на локальной машине

<pre><code>
sudo route add -net 10.98.88.0/24 gw 192.168.196.134
</pre></code>

где 10.98.88.0 подсеть EXTERNAL-IP

<H3>Запустить Flux</H3>

Устанавливаем Flux 2
<pre><code>
mkdir flux2
cd flux2
wget https://fluxcd.io/install.sh
chmod u+x install.sh
./install.sh
</pre></code>

Привязываем Flux2 к репозиторию Infra
<pre><code>
export GITLAB_TOKEN="glpat--_rsAfF48UjFmcyZ529p"
flux bootstrap gitlab --verbose --components-extra=image-reflector-controller,image-automation-controller --owner=otus43 --repository=Infra --branch=main --path=deploy/releases --token-auth --personal
</pre></code>

Получаем
<pre><code>
► connecting to https://gitlab.com
► cloning branch "main" from Git repository "https://gitlab.com/otus43/Infra.git"
✔ cloned repository
► generating component manifests
✔ generated component manifests
✔ component manifests are up to date
► installing components in "flux-system" namespace
✔ installed components
✔ reconciled components
► determining if source secret "flux-system/flux-system" exists
► generating source secret
► applying source secret "flux-system/flux-system"
✔ reconciled source secret
► generating sync manifests
✔ generated sync manifests
✔ sync manifests are up to date
► applying sync manifests
✔ reconciled sync configuration
◎ waiting for Kustomization "flux-system/flux-system" to be reconciled
✔ Kustomization reconciled successfully
► confirming components are healthy
✔ helm-controller: deployment ready
✔ image-automation-controller: deployment ready
✔ image-reflector-controller: deployment ready
✔ kustomize-controller: deployment ready
✔ notification-controller: deployment ready
✔ source-controller: deployment ready
✔ all components are healthy
</pre></code>

Установка Helm operator
<pre><code>
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
kubectl create namespace flux
helm repo add fluxcd https://charts.fluxcd.io
helm upgrade --install helm-operator fluxcd/helm-operator -f helm-operator.values.yaml --namespace flux-system


helm upgrade -i helm-operator fluxcd/helm-operator --wait \
--namespace flux-system \
--set git.ssh.secretName=flux-git-deploy \
--set helm.versions=v3
</pre></code>

Устоновим Service monitor
<pre><code>
LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | kubectl create -f -
</pre></code>

Удалим Flux2

flux uninstall

Установим ArgoCD

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


Download and instal argoCD CLI tool
wget https://github.com/argoproj/argo-cd/releases/download/v2.5.9/argocd-linux-amd64
chmod +x argocd-linux-amd64
mv argocd-linux-amd64 /usr/local/bin/argocd

Get admin credentials
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

Deploy Application
argocd login localhost:8080 --username admin
argocd app create adservice -f deploy/argocd/apps/adservice.yaml
