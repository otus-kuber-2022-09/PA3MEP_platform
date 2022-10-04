# PA3MEP_platform

<H1> Dockerfile </H1>
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

<H1>Kubernetes POD</H1>
Описываем наш POD используем образ созданый ранее и запускаем.
<pre><code>kubectl apply -f web-pod.yaml</pre></code>

Перенаправляем порт 8000
<pre><code>kubectl port-forward --address 0.0.0.0 pod/web 8000:8000</pre></code>

Проверяем. В этом случае указывать HTML файл не нужно, потому что initContainer создал нам свой index.html
<pre><code>curl -vvv http://localhost:8080/</pre></code>

<H1>Frontend</H1>

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

