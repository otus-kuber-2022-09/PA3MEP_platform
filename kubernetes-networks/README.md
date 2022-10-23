<H1>ДЗ день 4</H1>
Add and test readness probe

<pre><code>kubectl apply -f kubernetes-intro/web-pod.yaml</pre></code>

Readness probe failed

Readiness probe failed: Get "http://10.32.0.2:80/index.html": dial tcp 10.32.0.2:80: connect: connection refused

Add and test liveness probe

<pre><code>livenessProbe:
      tcpSocket: 
        port: 8000</pre></code>

И ничего не изменилось. Видимо livenessProbe не запускается если readnessProbe возвращает ошибку.

<H2>Вопрос для самопроверки</H2>
<H3>Почему следующая конфигурация валидна, но не имеет смысла?</H3>
В данном контексте эта проба так же не запустится пока readnessProbe в ошибке.
А в общем он не имеет смысла потому что если процесс веб-сервера аварийно завершит работу, то и ПОД не дойдёт то состояния Running и будет перезапускаться.
Это произойдёт потому что при создании образа, в данном случае httpd:2.4, указано
CMD ["httpd-foreground"]
И если этот процесс завершит работу, не важно аварийно или нет, то существование ПОДа не будет иметь смысла и он будет перезапущен.

<H3>Бывают ли ситуации, когда она все-таки имеет смысл?</H3>
Да, бывают. Например когда внутри ПОДа необходимо отслеживать какой-то стороний процесс.

Создаём и запускаем деплоймент и так же исправляем readnessProbe.
<pre><code>kubectl apply -f kubernetes-networks/web-deploy.yaml</pre></code>

Теперь все ПОДы запустились корректно
<pre><code>kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
web-546c587fdb-ht6n8   1/1     Running   0          6s
web-546c587fdb-lrwnq   1/1     Running   0          6s
web-546c587fdb-x7bjc   1/1     Running   0          6s</pre></code>

<pre><code>kubectl describe pod web-546c587fdb-ht6n8
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True</pre></code>

<H2>Deployment | Самостоятельная работа</H2>
<H3>maxSurge: 0 maxUnavailable: 0</H3>
<pre><code>
kubectl apply -f web-deploy.yaml
The Deployment "web" is invalid: spec.strategy.rollingUpdate.maxUnavailable: Invalid value: intstr.IntOrString{Type:0, IntVal:0, StrVal:""}: may not be 0 when `maxSurge` is 0
</pre></code>
Что, в принципе логично

<H3>maxSurge: 0 maxUnavailable: 100%</H3>
Все ПОДы обновились одновременно.

<H3>maxSurge: 100 maxUnavailable: 0</H3>
Все ПОДы обновились одновременно. Но тут был момент когда в кластере сосуществовали 6 подов. То есть старый ReplicaSet был удалён только тогда когда все ПОДы
нового деплоймента вышли в статус Ready

<H3>maxSurge: 100 maxUnavailable: 100</H3>
Все ПОДы обновились одновременно. Поведение похоже, с той лишь разницей что старый ReplicaSet был сразу удалён.

<H2>Создание Service | ClusterIP</H2>
Запускаем сервис

<pre><code>
kubectl apply -f web-svc-cip.yaml
service/web-svc-cip created
</pre></code>

<pre><code>
kubectl get service
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP   13h
web-svc-cip   ClusterIP   10.105.199.231   <none>        80/TCP    18s
</pre></code>

Проверяем доступность сервиса

<pre><code>
minikube ssh
docker@minikube:~$ curl http://10.105.199.231/index.html
</pre></code>

<H2>Установка MetalLB</H2>
<pre><code>
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl --namespace metallb-system get all
kubectl apply -f metallb-config.yaml
kubectl apply -f web-svc-lb.yaml
 kubectl --namespace metallb-system logs pod/controller-69bcb9c949-88fx5
</pre></code>

Добавляем route и проверяем нащ setup
<pre><code>
minikube ssh
ip addr show eth0
exit
sudo ip route add 172.17.255.0/24 via 192.168.49.2
curl http://172.17.255.1/index.html
</pre></code>

<H2>DNS over MetalLB</H2>
Манифест находится в coredns/coredns.yaml.
Сначала стоит убедиться что порты 53 у нас свободны и при необходимости их освободить
<pre><code>
kubectl get svc --all-namespaces
</pre></code>

Смотрим столбец PORT(S) что там не было портов 53. Если всё таки есть, как было у меня, то придётся снести сервис который его занимает
<pre><code>
kubectl delete svc kube-dns -n kube-system
</pre></code>

И затем запускаем наш ДНС через балансировщик
<pre><code>
kubectl apply -f coredns/coredns.yaml
</pre></code>

Проверяем
<pre><code>
host -T web.default.cluster.local 172.17.255.10
Using domain server:
Name: 172.17.255.10
Address: 172.17.255.10#53
Aliases: 

Host web.default.cluster.local not found: 3(NXDOMAIN)
</pre></code>

<pre><code>
host -U web.default.cluster.local 172.17.255.10
Using domain server:
Name: 172.17.255.10
Address: 172.17.255.10#53
Aliases: 

Host web.default.cluster.local not found: 3(NXDOMAIN)
</pre></code>

<H2>Ingress</H2>
Запускаем

<pre><code>
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
kubectl apply -f nginx-lb.yaml
</pre></code>

Проверяем
<pre><code>
curl http://172.17.255.2
404 Not Found
</pre></code>

<pre><code>
kubectl apply -f web-svc-headless.yaml
kubectl get svc web-svc
NAME      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
web-svc   ClusterIP   None         <none>        80/TCP    34s
</pre></code>

Создаём правила Ingress
<pre><code>
kubectl apply -f web-ingress.yaml
kubectl describe ingress/web
NAME      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
web-svc   ClusterIP   None         <none>        80/TCP    34s
</pre></code>
Пришлось не много видоизменить манифест.

apiVersion: networking.k8s.io/v1beta1 заменил на apiVersion: networking.k8s.io/v1
добавил ingressClassName: nginx и pathType: Prefix

Проверяем браузером. http://172.17.255.2/web/index.html Нас вежливо перенаправили на HTTPS даже.

<H2>Dashboard</H2>
<pre><code>
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
</pre></code>

Видим сервис 

<pre><code>
kubernetes-dashboard   service/kubernetes-dashboard                 ClusterIP      10.106.166.238   <none>          443/TCP                      52s
</pre></code>

Туда нам, видимо и надо.

<pre><code>
kubectl describe svc kubernetes-dashboard -n kubernetes-dashboard
</pre></code>

Создаём Ингресс и говорим ему что backend требует SSL
<pre><code>
kubectl apply -f dashboard/dashboard-ingress.yaml
</pre></code>

Тестируем
<pre><code>
curl -vvv -k https://172.17.255.2/dashboard
</pre></code>

В ответ приходит кусок HTMLа
<title>Kubernetes Dashboard</title>

