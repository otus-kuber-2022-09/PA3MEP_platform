<H1>ДЗ день 3</H1>
Kind installation
<pre><code>curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind</pre></code>

Create cluster
<pre><code>kind create cluster --config /home/tony/Documents/src/Notes/2/kind-config.yaml
kubectl get nodes</pre></code>

REPLICASET
Deploy Frontend ReplicaSet
<pre><code>kubectl apply -f frontend-replicaset.yaml
kubectl get pods -l app=frontend</pre></code>

Scale up
<pre><code>kubectl scale replicaset frontend --replicas=3
kubectl get rs frontend</pre></code>

Kill yem all
<pre><code>kubectl delete pods -l app=frontend | kubectl get pods -l app=frontend -w</pre></code>

Create v2
<pre><code>docker image tag pa3mep/frontend:1.0 pa3mep/frontend:2.0
docker login --username pa3mep
docker image push pa3mep/frontend:2.0</pre></code>

Deploy v2.0
<pre><code>kubectl apply -f frontend-replicaset.yaml</pre></code>

Check status
Get ReplicaSet image definition
<pre><code>kubectl get replicaset frontend -o=jsonpath='{.spec.template.spec.containers[0].image}}'</pre></code>

Get ReplicaSet actual image
<pre><code>kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}'</pre></code>

Delete PODs manualy
<pre><code>kubectl get pods
kubectl delete pods frontend-786s5</pre></code>

Обновление не произошло автоматически потому что количество реплик 3 не даёт ReplicaSet-у 
запустить ещё один POD, а так же удалить хотя бы один POD старой версии.

DEPLOYMENT
Подготовка
<pre><code>docker build -t pa3mep/paymentservice:1.0 .
docker image tag pa3mep/paymentservice:1.0 pa3mep/paymentservice:2.0
docker image push pa3mep/paymentservice:1.0
docker image push pa3mep/paymentservice:2.0</pre></code>

Deploy
<pre><code>kubectl delete -f paymentservice-replicaset.yaml
kubectl apply -f paymentservice-deployment.yaml
kubectl get deployments
kubectl get rs
kubectl get pods</pre></code>

Upgrade to v2.0
<pre><code>kubectl apply -f paymentservice-deployment.yaml
kubectl rollout history deployment paymentservice
kubectl get pods -l app=paymentservice -o=jsonpath='{.items[0:3].spec.containers[0].image}'</pre></code>

Rollback to version 1.0
<pre><code>kubectl rollout undo deployment paymentservice --to-revision=1</pre></code>

Upgrade to v2.0 blue-green
<pre><code>kubectl apply -f paymentservice-deployment-bg.yaml</pre></code>
Rollback
<pre><code>kubectl rollout history deployment paymentservice
kubectl rollout undo deployment paymentservice --to-revision=5</pre></code>

Upgrade to v2.0. Rolling
<pre><code>kubectl apply -f paymentservice-deployment-reverse.yaml</pre></code>

DaemonSet
<pre><code>https://devopscube.com/node-exporter-kubernetes/
kubectl apply -f node-exporter-daemonset.yaml
kubectl port-forward node-exporter-44dwv 9100:9100</pre></code>

Add toleration
<pre><code>template:
    metadata:
      labels:
        app.kubernetes.io/component: exporter
        app.kubernetes.io/name: node-exporter
    spec:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          effect: "NoSchedule"

kubectl apply -f node-exporter-daemonset.yaml</pre></code>

<H1>ДЗ день 2</H1>
<H2> Dockerfile </H2>
За основу берём образ httpd версии 2.4 из DockerHub. В процессе создания нашего образа переписываем следующие файлы:

* /etc/passwd и /etc/group - в нашеё версии UID и GID пользователя www-data изменены на 1001
* httpd.conf - тут меняем порт на 8000 и DocumentRoot на /app

Собираем образ 
<pre><code>docker build -t pa3mep/kubernetes-intro:1.1 .</pre></code>

Запускаем
<pre><code>docker run -p 8000:8000 -dit --name web pa3mep/kubernetes-intro:1.1</pre></code>

Перенаправляем порт 8000
<pre><code>kubectl port-forward --address 0.0.0.0 pod/web 8000:8000</pre></code>

Проверяем
<pre><code>curl -vvv http://localhost:8080/homework.html</pre></code>

Публикуем на DockerHub
<pre><code>docker login --username pa3mep
docker push pa3mep/kubernetes-intro:1.1</pre></code>

<H2>Kubernetes POD</H2>
Описываем наш POD используем образ созданый ранее и запускаем.
<pre><code>kubectl apply -f web-pod.yaml</pre></code>

Перенаправляем порт 8000
<pre><code>kubectl port-forward --address 0.0.0.0 pod/web 8000:8000</pre></code>

Проверяем. В этом случае указывать HTML файл не нужно, потому что initContainer создал нам свой index.html
<pre><code>curl -vvv http://localhost:8080/</pre></code>

<H2>Frontend</H2>

Клонируем GIT репо
<pre><code>git clone https://github.com/GoogleCloudPlatform/microservices-demo.git</pre></code>

Собираем образ Frontend
<pre><code>cd src/frontend/
docker build -t frontend:1.0 .</pre></code>

Добавляем тэг для DockerHub
<pre><code>docker image tag frontend:1.0 pa3mep/frontend:1.0</pre></code>

Заливаем на DockerHub
<pre><code>docker login --username pa3mep
docker push pa3mep/frontend:1.0</pre></code>

Запускаем
<pre><code>kubectl run frontend --image pa3mep/frontend:1.0 --restart=Never</pre></code>

POD остаётся в ошибке. Ищем причину
<pre><code>kubectl logs frontend</pre></code>

panic: environment variable "PRODUCT_CATALOG_SERVICE_ADDR" not set

Исправляем путём добавления блока env в манифест и перезапускаем
<pre><code>kubectl delete -f frontend.yaml
kubectl apply -f frontend-pod-healthy.yaml</pre></code>

На этом пока всё

