<H1>Kubernetes Dashboard installation</H1>

<pre><code>
cd kubernetes-dashboard/
kubectl apply -f 1-serviceaccount.yaml
kubectl apply -f 1-serviceaccount.yaml
kubectl proxy
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
kubectl -n kubernetes-dashboard create token admin-user
</pre></code>



