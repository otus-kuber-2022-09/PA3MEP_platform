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

