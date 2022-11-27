<H1>ДЗ день 8</H1>

Build custom nginx image

<pre><code>
cd kubernetes-monitoring/nginx
docker build -t pa3mep/nginx:1.3 kubernetes-monitoring/nginx/
docker login --username pa3mep
docker push pa3mep/nginx:1.3
</pre></code>

Deploy nginx custom image

<pre><code>
kubectl apply -f kubernetes-monitoring/nginx/nginx.yaml
</pre></code>

Deploy Prometheus CRDs
<pre><code>
LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | kubectl create -f -
</pre></code>

Deploy Prometheus
<pre><code>
kubectl apply -f kubernetes-monitoring/prometheus/prometheus.yaml
</pre></code>

Deploy Prometheus service monitor
<pre><code>
kubectl apply -f kubernetes-monitoring/ServiceMonitor.yaml
</pre></code>



