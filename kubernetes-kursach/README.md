<H1>Курсовой проэкт</H1>

<H2>Первоначальный план</H2>
Запустить Хипстер Шоп на Кубернетесе
    Собрать образы Хипстер шопа
    Автоматически выложить образы на ДокерХаб
Запустить ХипстерШоп с помошью Flux
    Настроить кластер Кубернетеса on-prem
    Запустить istio
    Запустить Flux
Автоматически обновить ХипстерШоп до следующей версии

<H2>Запустить Хипстер Шоп на Кубернетесе</H2>
<H3>Собрать образы Хипстер шопа</H3>

Репозиторий: https://gitlab.com/otus43/microservices-demo/-/tree/main
CI Pipeline: https://gitlab.com/otus43/microservices-demo/-/pipelines

<H3>Автоматически выложить образы на ДокерХаб</H3>

Репозитории ДокерХаб: 

https://hub.docker.com/repository/docker/pa3mep/adservice
https://hub.docker.com/repository/docker/pa3mep/frontend/general
https://hub.docker.com/repository/docker/pa3mep/cartservice/general
https://hub.docker.com/repository/docker/pa3mep/checkoutservice/general
https://hub.docker.com/repository/docker/pa3mep/currencyservice/general
https://hub.docker.com/repository/docker/pa3mep/emailservice/general
https://hub.docker.com/repository/docker/pa3mep/loadgenerator/general
https://hub.docker.com/repository/docker/pa3mep/paymentservice/general
https://hub.docker.com/repository/docker/pa3mep/productcatalogservice/general
https://hub.docker.com/repository/docker/pa3mep/recommendationservice/general
https://hub.docker.com/repository/docker/pa3mep/shippingservice/general

<H2>Запустить ХипстерШоп с помошью Flux</H2>
<H3>Настроить кластер Кубернетеса on-prem</H3>

Получившийся кластер выглядит сдедующим образом
<pre><code>
kubectl get nodes
NAME           STATUS   ROLES                  AGE   VERSION
kubik-master   Ready    control-plane,master   26d   v1.23.15
kubik-node-1   Ready    <none>                 26d   v1.23.15
kubik-node-2   Ready    <none>                 26d   v1.23.15
kubik-node-3   Ready    <none>                 9d    v1.23.15
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

kubectl get all -n istio-system
NAME                                        READY   STATUS    RESTARTS   AGE
pod/grafana-b854c6c8-7h85p                  1/1     Running   0          77s
pod/istio-egressgateway-7475c75b68-lfhjv    1/1     Running   0          4m19s
pod/istio-ingressgateway-6688c7f65d-tbfhb   1/1     Running   0          4m19s
pod/istiod-885df7bc9-7nw8j                  1/1     Running   0          3m52s
pod/jaeger-54b7b57547-w9n76                 1/1     Running   0          77s
pod/kiali-5ff88f8595-kcsjd                  1/1     Running   0          76s
pod/prometheus-7b8b9dd44c-nsfvk             2/2     Running   0          76s

NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                      AGE
service/grafana                ClusterIP      10.100.15.172    <none>        3000/TCP                                                                     77s
service/istio-egressgateway    ClusterIP      10.110.233.194   <none>        80/TCP,443/TCP                                                               4m19s
service/istio-ingressgateway   LoadBalancer   10.98.88.168     <pending>     15021:31094/TCP,80:32307/TCP,443:30251/TCP,31400:31166/TCP,15443:31976/TCP   4m19s
service/istiod                 ClusterIP      10.106.161.36    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                                        9m20s
service/jaeger-collector       ClusterIP      10.107.243.235   <none>        14268/TCP,14250/TCP,9411/TCP                                                 77s
service/kiali                  ClusterIP      10.104.177.99    <none>        20001/TCP,9090/TCP                                                           76s
service/prometheus             ClusterIP      10.102.140.28    <none>        9090/TCP                                                                     76s
service/tracing                ClusterIP      10.103.227.36    <none>        80/TCP,16685/TCP                                                             77s
service/zipkin                 ClusterIP      10.111.255.66    <none>        9411/TCP                                                                     77s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana                1/1     1            1           77s
deployment.apps/istio-egressgateway    1/1     1            1           4m20s
deployment.apps/istio-ingressgateway   1/1     1            1           4m20s
deployment.apps/istiod                 1/1     1            1           9m20s
deployment.apps/jaeger                 1/1     1            1           77s
deployment.apps/kiali                  1/1     1            1           76s
deployment.apps/prometheus             1/1     1            1           76s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/grafana-b854c6c8                  1         1         1       77s
replicaset.apps/istio-egressgateway-7475c75b68    1         1         1       4m19s
replicaset.apps/istio-ingressgateway-6688c7f65d   1         1         1       4m19s
replicaset.apps/istiod-885df7bc9                  1         1         1       9m20s
replicaset.apps/jaeger-54b7b57547                 1         1         1       77s
replicaset.apps/kiali-5ff88f8595                  1         1         1       76s
replicaset.apps/prometheus-7b8b9dd44c             1         1         1       76s
</pre></code>