# Курсовой проект

## Первоначальный план
1. Запустить Хипстер Шоп на Кубернетесе
    1. Собрать образы Хипстер шопа
    2. Автоматически выложить образы на ДокерХаб
2. Запустить ХипстерШоп с помошью argoCD
    1. Настроить кластер Кубернетеса
    2. Запустить argoCD и настроить его
    3. Запустить Хипстершоп
    4. Вывести в интернет Frontend
3. Экстра фичи
    1. Установить ingress контроллер
    2. Установить cert-manager
    3. Настроить Let's Encrypt SSL для Frontend
4. Автоматически обновить ХипстерШоп до следующей версии

## 1. Запустить Хипстер Шоп на Кубернетесе
### 1.1 Собрать образы Хипстер шопа

* Репозиторий: https://gitlab.com/otus43/microservices-demo/-/tree/main
* CI Pipeline: https://gitlab.com/otus43/microservices-demo/-/pipelines
* Репозиторий инфраструктуры: https://gitlab.com/otus43/infra

### 1.2 Автоматически выложить образы на ДокерХаб

Репозитории ДокерХаб: 

* https://hub.docker.com/repository/docker/pa3mep/adservice
* https://hub.docker.com/repository/docker/pa3mep/frontend/general
* https://hub.docker.com/repository/docker/pa3mep/cartservice/general
* https://hub.docker.com/repository/docker/pa3mep/checkoutservice/general
* https://hub.docker.com/repository/docker/pa3mep/currencyservice/general
* https://hub.docker.com/repository/docker/pa3mep/emailservice/general
* https://hub.docker.com/repository/docker/pa3mep/loadgenerator/general
* https://hub.docker.com/repository/docker/pa3mep/paymentservice/general
* https://hub.docker.com/repository/docker/pa3mep/productcatalogservice/general
* https://hub.docker.com/repository/docker/pa3mep/recommendationservice/general
* https://hub.docker.com/repository/docker/pa3mep/shippingservice/general

## 2. Запустить ХипстерШоп с помошью argoCD
### 2.1 Настроить кластер Кубернетеса

Кубернетес кластер запустим на Google Cloud. Получившийся кластер выглядит сдедующим образом

<pre><code>
kubectl get nodes
NAME                                  STATUS   ROLES    AGE   VERSION
gke-otus-default-pool-61b1c61f-8sxv   Ready    <none>   29m   v1.24.8-gke.2000
gke-otus-default-pool-61b1c61f-s9nk   Ready    <none>   30m   v1.24.8-gke.2000
gke-otus-default-pool-61b1c61f-x20p   Ready    <none>   29m   v1.24.8-gke.2000
</pre></code>

### 2.2 Запустить argoCD и настроить его

<pre><code>
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
</pre></code>


Скачаем и установим argoCD CLI tool. Утилита не обязательна, но полезна.

<pre><code>
wget https://github.com/argoproj/argo-cd/releases/download/v2.5.9/argocd-linux-amd64
chmod +x argocd-linux-amd64
mv argocd-linux-amd64 /usr/local/bin/argocd
</pre></code>

Чтобы получить автоматически сгенерированный пароль админа, используем следующую команду

<pre><code>
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
</pre></code>

### 2.3 Запустить Хипстершоп

Самый простой вариант запустить приложение с помощью argoCD это использовать CLI утилиту. Предварительно, конечно, необходимо настроить репозитории и проекты. Это можно сделать с помощью WEB UI.<br>
Манифесты всех приложений можно найти в репозитории инфраструктуры https://gitlab.com/otus43/infra/-/tree/main/deploy/argocd/apps

<pre><code>
argocd login localhost:8080 --username admin
argocd app create adservice -f deploy/argocd/apps/adservice.yaml
argocd app create cartservice -f deploy/argocd/apps/cartservice.yaml
argocd app create checkoutservice -f deploy/argocd/apps/checkoutservice.yaml
argocd app create currencyservice -f deploy/argocd/apps/currencyservice.yaml
argocd app create emailservice -f deploy/argocd/apps/emailservice.yaml
argocd app create frontend -f deploy/argocd/apps/frontend.yaml
argocd app create loadgenerator -f deploy/argocd/apps/loadgenerator.yaml
argocd app create paymentservice -f deploy/argocd/apps/paymentservice.yaml
argocd app create productcatalogservice -f deploy/argocd/apps/productcatalogservice.yaml
argocd app create recommendationservice -f deploy/argocd/apps/recommendationservice.yaml
argocd app create shippingservice -f deploy/argocd/apps/shippingservice.yaml
argocd app list
argocd app delete argocd/adservice
argocd app delete argocd/cartservice
argocd app delete argocd/checkoutservice
argocd app delete argocd/currencyservice
argocd app delete argocd/emailservice
argocd app delete argocd/frontend
argocd app delete argocd/loadgenerator
argocd app delete argocd/paymentservice
argocd app delete argocd/productcatalogservice
argocd app delete argocd/recommendationservice
argocd app delete argocd/shippingservice
</pre></code>

Но, предпочтительнее, всё таки, применять декларативный подход.

### 2.4 Вывести в интернет Frontend

Меняем тип сервиса для Frontend на LoadBalancer и получаем внешний IP. Наш argoCD автоматически обновит наш сервис, нам остаётся только наблюдать за процессом.
В итоге наш Frontend доступен без прокидывания портов через localhost

http://35.228.123.225.nip.io/


## 3. Экстра фичи

### 3.1 Установить ingress контроллер
Переводим наш ХипстерШоп обратно на ClusterIP

**Создаём ArgoCD репозиторий для Nginx Ingress**<br>
https://gitlab.com/otus43/infra/-/blob/main/deploy/argocd/repos/ingress-nginx.yaml<br>
kubectl apply -f deploy/argocd/projects/ingress-nginx.yaml

**Создаём ArgoCD проект**<br>
https://gitlab.com/otus43/infra/-/blob/main/deploy/argocd/projects/ingress-nginx.yaml<br>
kubectl apply -f deploy/argocd/projects/ingress-nginx.yaml

**ArgoCD Application**<br>
https://gitlab.com/otus43/infra/-/blob/main/deploy/argocd/apps/ingress-nginx.yaml<br>
kubectl apply -f deploy/argocd/apps/ingress-nginx.yaml


http://35.228.123.225.nip.io/
https://35.228.123.225.nip.io/


### 3.2 Установить cert-manager

Его установим вручную и Хелмом

<pre><code>
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.11.0 --set installCRDs=true
</pre></code>

Добавим ClusterIssuer для Lets Encrypt

<pre><code>
https://gitlab.com/otus43/infra/-/blob/main/deploy/argocd/cert-manager/ClusterIssuer.yaml
kubectl apply -f deploy/argocd/cert-manager/ClusterIssuer.yaml
</pre></code>

### 3.3 Настроить Let's Encrypt SSL для Frontend
Обновим наш Frontend чтобы он использовал валидный сертификат Lets Encrypt<br>
https://gitlab.com/otus43/infra/-/blob/main/deploy/argocd/resources/frontend/frontend.yaml#L89<br>
Обновится он сам благодоря нашему argoCD

## 4. Автоматически обновить ХипстерШоп до следующей версии










<br><br><br><br><br><br><br><br>


# Если останется время можно разобраться

KUBE SEAL

https://github.com/bitnami-labs/sealed-secrets


https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.4/kubeseal-0.19.4-linux-amd64.tar.gz

tar -xf kubeseal-0.19.4-linux-amd64.tar.gz
chmod +x kubeseal
sudo mv kubeseal /usr/local/bin/

kubeseal --version
kubeseal version: 0.19.4

Устанавливаем kubeseal controller

export USER_EMAIL=leo.koteika@gmail.com
kubectl create clusterrolebinding $USER-cluster-admin-binding --clusterrole=cluster-admin --user=$USER_EMAIL
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.4/controller.yaml

Создадим sealed секрет для пароля GitLab

export username=pa3mep
export password=password123

echo $username | base64
echo $password | base64

cat <<EOF > /tmp/ingress-nginx-git-repo.yaml
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: null
  name: ingress-nginx-git-repo
  namespace: argocd:
  password: password-base64
  username: username-base64
EOF

cd ~/Documents/src/infra/

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials otus \
  --region europe-north1-b \
  --project flash-ascent-375419 \
  --internal-ip

cat /tmp/ingress-nginx-git-repo.yaml | kubeseal \
    --controller-namespace kube-system \
    --controller-name sealed-secrets-controller \
    --format yaml \
    > deploy/argocd/sealed-secrets/ingress-nginx-git-repo.yaml


Не работает и надоело. Если останется время, будем разбираться. Короче

kubectl apply -f deploy/argocd/repos/ingress-nginx.yaml

ArgoCD Application
kubectl apply -f deploy/argocd/apps/ingress-nginx.yaml