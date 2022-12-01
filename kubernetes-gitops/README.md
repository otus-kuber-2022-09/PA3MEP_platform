<H1>ДЗ день 14. GitOps и инструменты поставки</H1>

<H2>Подготовка Kubernetes кластера. Установка istio</H2>

Использованные материалы
<pre><code>
https://istio.io/v1.2/docs/setup/kubernetes/install/platform/gke/
https://istio.io/latest/docs/setup/getting-started/
</pre></code>

Сливаем последнюю версию istio
<pre><code>
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.16.0/bin
sudo mv istioctl /usr/bin
</pre></code>

Устанавливаем
<pre><code>
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system
</pre></code>


Итого
kubectl get all -n istio-system
<pre><code>
W1121 15:24:53.828861   13292 gcp.go:119] WARNING: the gcp auth plugin is deprecated in v1.22+, unavailable in v1.26+; use gcloud instead.
To learn more, consult https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
NAME                                        READY   STATUS    RESTARTS   AGE
pod/istio-egressgateway-d84b5f89f-sphmk     1/1     Running   0          2m
pod/istio-ingressgateway-869ccf7495-snzkb   1/1     Running   0          2m
pod/istiod-689fd979b-5r7z5                  1/1     Running   0          2m11s

NAME                           TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                                      AGE
service/istio-egressgateway    ClusterIP      10.36.3.21     <none>        80/TCP,443/TCP                                                               2m
service/istio-ingressgateway   LoadBalancer   10.36.10.237   34.88.78.13   15021:30255/TCP,80:32533/TCP,443:30630/TCP,31400:30044/TCP,15443:32148/TCP   2m
service/istiod                 ClusterIP      10.36.9.44     <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                                        2m12s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-egressgateway    1/1     1            1           2m1s
deployment.apps/istio-ingressgateway   1/1     1            1           2m1s
deployment.apps/istiod                 1/1     1            1           2m12s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-egressgateway-d84b5f89f     1         1         1       2m1s
replicaset.apps/istio-ingressgateway-869ccf7495   1         1         1       2m1s
replicaset.apps/istiod-689fd979b                  1         1         1       2m12s
</pre></code>

<H2>Frontend</H2>
<pre><code>
stages:
  - build

docker_build:
  image: docker:latest
  stage: build
  services:
    - docker:dind
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  script:
    - cd src/frontend
    - docker build -t $CI_FRONTEND_IMAGE:$CI_JOB_ID .
    - echo "Compile complete."
    - docker push "$CI_FRONTEND_IMAGE:$CI_JOB_ID"
</pre></code>
kubernetes-gitops/gitlab/gitlab-ci.yml

<H2>DockerHub Repositories</H2>

https://hub.docker.com/repository/docker/pa3mep/frontend
https://hub.docker.com/repository/docker/pa3mep/adservice
https://hub.docker.com/repository/docker/pa3mep/checkoutservice
https://hub.docker.com/repository/docker/pa3mep/cartservice
https://hub.docker.com/repository/docker/pa3mep/shippingservice
https://hub.docker.com/repository/docker/pa3mep/recommendationservice
https://hub.docker.com/repository/docker/pa3mep/productcatalogservice
https://hub.docker.com/repository/docker/pa3mep/loadgenerator
https://hub.docker.com/repository/docker/pa3mep/emailservice
https://hub.docker.com/repository/docker/pa3mep/currencyservice
https://hub.docker.com/repository/docker/pa3mep/paymentservice

<H2>GitOps - Подготовка</H2>

kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml

<H2>Установка Flux</H2>
<pre><code>
helm repo add fluxcd https://charts.fluxcd.io
kubectl create namespace flux
helm upgrade --install flux fluxcd/flux -f flux.values.yaml --namespace flux
</pre></code>

Flux v1 depricated и работает не корректно. Перейдём на версию 2
<pre><code>
cd flux2
wget https://fluxcd.io/install.sh
chmod u+x install.sh
./install.sh
export GITLAB_TOKEN="glpat--_rsAfF48UjFmcyZ529p"
flux bootstrap gitlab --components-extra=image-reflector-controller,image-automation-controller --owner=otus43 --repository=Infra --branch=main --path=deploy/releases --token-auth --personal
</pre></code>

<H2>Установка Helm operator</H2>
<pre><code>
helm upgrade --install helm-operator fluxcd/helm-operator -f helm-operator.values.yaml --namespace flux
</pre></code>

<H2>HelmRelease | Проверка</H2>

Получилось что frontend у нас зависит от ServiceMonitor ресурса, который в свою очередь является частью установки Prometheus.

<pre><code>
kubectl describe HelmRelease frontend -n microservices-demo

Warning  FailedReleaseSync  8m29s (x501 over 4h23m)  helm-operator  synchronization of release 'frontend' in namespace 'microservices-demo' failed: installation failed: unable to build kubernetes objects from release manifest: unable to recognize "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"
</pre></code>

Устоновим Service monitor
<pre><code>
LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | kubectl create -f -
</pre></code>

И через некоторое время наш HelmRelease перейдёт в статус 

<pre><code>
Normal   ReleaseSynced      4m45s (x3 over 6m40s)  helm-operator  managed release 'frontend' in namespace 'microservices-demo' synchronized
</pre></code>

<H2>Обновление образа</H2>

![](img/VersionUpdate.png)

<pre><code>
ts=2022-11-22T17:53:39.449727104Z caller=helm.go:69 component=helm version=v3 info="Created a new Deployment called \"frontend-hipster\" in microservices-demo\n" targetNamespace=microservices-demo release=frontend
ts=2022-11-22T17:53:39.622575038Z caller=helm.go:69 component=helm version=v3 info="Deleting \"frontend\" in microservices-demo..." targetNamespace=microservices-demo release=frontend
ts=2022-11-22T17:53:39.706761483Z caller=helm.go:69 component=helm version=v3 info="updating status for upgraded release for frontend" targetNamespace=microservices-demo release=frontend
ts=2022-11-22T17:53:39.791761524Z caller=release.go:364 component=release release=frontend targetNamespace=microservices-demo resource=microservices-demo:helmrelease/frontend helmVersion=v3 info="upgrade succeeded" revision=a9916208cad7175a2fb6afe9d9b787759c22f511 phase=upgrade
</pre></code>

<H2>Самостоятельное задание</H2>

![](img/DeployAllServices.png)
![](img/DeployAllServices2.png)

<H2>Неожиданно нашлась ошибочка</H2>
Не запускается cartservice deployment. Как бы вообще. Начал копать. Нашёл что helm-operator ругается

<pre><code>
kubectl logs helm-operator-55769d46b8-mq28t -n flux -f | grep cartservice

ts=2022-11-24T15:41:36.779011235Z caller=release.go:79 component=release release=cartservice targetNamespace=microservices-demo resource=microservices-demo:helmrelease/cartservice helmVersion=v3 info="starting sync run"

ts=2022-11-24T15:41:37.511471555Z caller=release.go:85 component=release release=cartservice targetNamespace=microservices-demo resource=microservices-demo:helmrelease/cartservice helmVersion=v3 error="failed to prepare chart for release: no cached repository for helm-manager-1067d9c6027b8c3f27b49e40521d64be96ea412858d8e45064fa44afd3966ddc found. (try 'helm repo update'): open /root/.cache/helm/repository/helm-manager-1067d9c6027b8c3f27b49e40521d64be96ea412858d8e45064fa44afd3966ddc-index.yaml: no such file or directory"
</pre></code>

В итоге удалось упоминание о подобной проблеме на великом stackoverflow

https://stackoverflow.com/questions/69366467/updating-helm-subcharts-fails-without-a-clear-error

Требовалось заменить 

<pre><code>
dependencies:
- name: redis
  version: 10.2.1
  repository: "https://kubernetes-charts.storage.googleapis.com/"
</pre></code>

на
<pre><code>
dependencies:
- name: redis
  version: 10.2.1
  repository: "https://charts.helm.sh/stable"
</pre></code>

И после этого появились ПОДы

<pre><code>
cartservice-547745cbfc-9z6kr             2/2     Running   0          21m
cartservice-redis-master-0               2/2     Running   0          21m
</pre></code>

Так же после этого пропала ошибка в ВЕБ интерфэйсе Frontend, которая говорила о том что cartservice не доступен, ну и как заключение корректно заработал LoadGenerator который до сих пор был застрявший в статусе Init видимо потому что не отрабатовал readness check, направленный на Frontend

<pre><code>
kubectl get pods -n microservices-demo
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-5f6cc88676-xbt4f               2/2     Running   0          93m
cartservice-547745cbfc-9z6kr             2/2     Running   0          21m
cartservice-redis-master-0               2/2     Running   0          21m
checkoutservice-7f859d9856-vhp5g         2/2     Running   0          87m
currencyservice-77997b9c5d-mnj2x         2/2     Running   0          84m
emailservice-7bdbb56f96-5pbnk            2/2     Running   0          83m
frontend-6cc46fd498-755rp                2/2     Running   0          28h
loadgenerator-7989595f7d-sfgjv           2/2     Running   0          156m
paymentservice-58f6c8b5c4-g5cl5          2/2     Running   0          79m
productcatalogservice-5d5846dd54-v5fl2   2/2     Running   0          77m
recommendationservice-8544968cb6-rntqb   2/2     Running   0          75m
shippingservice-8566755f88-9xln8         2/2     Running   0          73m
</pre></code>

<H2>Canary deployments с Flagger и Istio</H2>

Deploy the Istio operator

<pre><code>
istioctl operator init
istioctl operator init --watchedNamespaces=microservices-demo

kubectl apply -f IstioOperator.yaml

kubectl get IstioOperator -A
NAMESPACE            NAME                                   REVISION   STATUS    AGE
microservices-demo   microservices-demo-istiocontrolplane              HEALTHY   44s

kubectl get all -n istio-system
NAME                                        READY   STATUS    RESTARTS   AGE
pod/istio-egressgateway-d84b5f89f-l59zl     1/1     Running   0          100s
pod/istio-ingressgateway-869ccf7495-5clg6   1/1     Running   0          100s
pod/istiod-689fd979b-l5fwf                  1/1     Running   0          109s

NAME                           TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                                                      AGE
service/istio-egressgateway    ClusterIP      10.36.3.55     <none>         80/TCP,443/TCP                                                               100s
service/istio-ingressgateway   LoadBalancer   10.36.2.42     34.88.11.182   15021:31331/TCP,80:31249/TCP,443:31114/TCP,31400:32019/TCP,15443:30475/TCP   100s
service/istiod                 ClusterIP      10.36.11.120   <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP                                        109s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-egressgateway    1/1     1            1           100s
deployment.apps/istio-ingressgateway   1/1     1            1           100s
deployment.apps/istiod                 1/1     1            1           109s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-egressgateway-d84b5f89f     1         1         1       100s
replicaset.apps/istio-ingressgateway-869ccf7495   1         1         1       100s
replicaset.apps/istiod-689fd979b                  1         1         1       109s
</pre></code>

<H2>Установка Flagger</H2>

<pre><code>
helm repo add flagger https://flagger.app
kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml

helm upgrade --install flagger flagger/flagger --namespace=istio-system --set crd.create=false --set meshProvider=istio --set metricsServer=http://10.32.0.35:9090
</pre></code>

<H2>Istio | Sidecar Injection</H2>

<pre><code>
kubectl get ns microservices-demo --show-labels
NAME                 STATUS   AGE   LABELS
microservices-demo   Active   26h   fluxcd.io/sync-gc-mark=sha256.W_6VLRYgbwbK-GO3AOYggq9aT5JxXxCSLVsQgCg7kq4,istio-injection=enabled,kubernetes.io/metadata.name=microservices-demo

kubectl describe pod -l app=frontend -n microservices-demo
Containers:
  server:
    Container ID:   containerd://59a91ae04eb3bc4ccee88364670f7b99c28ef53871cedecaf9afaed872c9cd8e
    Image:          pa3mep/frontend:v0.0.2
    Image ID:       docker.io/pa3mep/frontend@sha256:a24767d32f0f0cab3315efdbda24489dd66a001e69cd83e3dfbcde8f9ffd4b34
  istio-proxy:
    Container ID:  containerd://dd1527fffd18ad725948bf3f502f4f2ea05970c3f8dbeab165b0a76a36296a7a
    Image:         docker.io/istio/proxyv2:1.16.0
    Image ID:      docker.io/istio/proxyv2@sha256:f6f97fa4fb77a3cbe1e3eca0fa46bd462ad6b284c129cf57bf91575c4fb50cf9
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11m   default-scheduler  Successfully assigned microservices-demo/frontend-6cc46fd498-755rp to gke-otus-gitops-default-pool-b7860ba6-9tcl
  Normal  Pulled     11m   kubelet            Container image "docker.io/istio/proxyv2:1.16.0" already present on machine
  Normal  Created    11m   kubelet            Created container istio-init
  Normal  Started    11m   kubelet            Started container istio-init
  Normal  Pulling    11m   kubelet            Pulling image "pa3mep/frontend:v0.0.2"
  Normal  Pulled     11m   kubelet            Successfully pulled image "pa3mep/frontend:v0.0.2" in 9.131442395s
  Normal  Created    11m   kubelet            Created container server
  Normal  Started    11m   kubelet            Started container server
  Normal  Pulled     11m   kubelet            Container image "docker.io/istio/proxyv2:1.16.0" already present on machine
  Normal  Created    11m   kubelet            Created container istio-proxy
  Normal  Started    11m   kubelet            Started container istio-proxy
</pre></code>

<H2>Доступ к frontend</H2>

<pre><code>
kubectl get gateway -n microservices-demo
NAME               AGE
frontend           28h
frontend-gateway   28h

kubectl get virtualservice -n microservices-demo
NAME       GATEWAYS       HOSTS   AGE
frontend   ["frontend"]   ["*"]   28h
</pre></code>

<H2>Flagger | Canary</H2>

После установки Flagger наблюдаеми следующие PODы в namespace istio-system

<pre><code>
kubectl get pods -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
flagger-5c5f959bfb-5lvwl                1/1     Running   0          118s
istio-egressgateway-d84b5f89f-l59zl     1/1     Running   0          7d23h
istio-ingressgateway-869ccf7495-5clg6   1/1     Running   0          7d23h
istiod-689fd979b-l5fwf                  1/1     Running   0          7d23h
</pre></code>

и в namespace microservices-demo

<pre><code>
kubectl get pods -n microservices-demo
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-774b47cd55-qrrb7               2/2     Running   0          43h
cartservice-77887657c6-gtg2x             2/2     Running   0          43h
cartservice-redis-master-0               2/2     Running   0          6d19h
checkoutservice-54ccdd8945-ptghf         2/2     Running   0          43h
currencyservice-6b94f8b745-x2frz         2/2     Running   0          43h
emailservice-5dc6958455-5zwx9            2/2     Running   0          43h
frontend-primary-77ccc68b49-7h88v        2/2     Running   0          2m43s
loadgenerator-8d9b575d7-l7gv5            2/2     Running   0          43h
paymentservice-b9fddddb5-pjtmx           2/2     Running   0          43h
productcatalogservice-5dfd45fd8c-tbslr   2/2     Running   0          43h
recommendationservice-6fb8cbfc6f-5v94j   2/2     Running   0          43h
shippingservice-67b5fd5-x4mn6            2/2     Running   0          43h
</pre></code>

Заметим что ПОД frontend у нас теперь с суфиксом primary что означает актуальную версию
Теперь создадим следующую версию и посмотрим что произойдёт.
Через некоторое время появился POD frontend-6c4859cbff-bksjp который представляет нашу новую версию

<pre><code>
NAME                                     READY   STATUS    RESTARTS   AGE
frontend-6c4859cbff-bksjp                1/2     Running   0          9s
frontend-primary-77ccc68b49-7h88v        2/2     Running   0          10m
</pre></code>

И через некоторое время старая версия была удалена и новая переименована в 

<pre><code>
frontend-primary-6f658d984b-d2mh6        2/2     Running   0          14m
</pre></code>

Можно заметить что хэш ПОДа остался, просто к имени добавился суффикс primary

<pre><code>
kubectl get canaries -n microservices-demo -o wide

NAME       STATUS      WEIGHT   FAILEDCHECKS   INTERVAL   MIRROR   STEPWEIGHT   STEPWEIGHTS   MAXWEIGHT   LASTTRANSITIONTIME
frontend   Succeeded   0        0              30s                                                        2022-12-01T14:44:30Z
</pre></code>