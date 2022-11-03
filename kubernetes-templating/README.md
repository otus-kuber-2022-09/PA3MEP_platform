<H1>ДЗ день 7</H1>

<H2>GCP Config </H2>
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-406.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-406.0.0-linux-x86_64.tar.gz

gcloud components install gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
gcloud container clusters get-credentials --zone europe-central2-a cluster-1
kubectl get nodes
NAME                                       STATUS   ROLES    AGE   VERSION
gke-cluster-1-default-pool-1b1a8331-hm5g   Ready    <none>   13m   v1.23.8-gke.1900
gke-cluster-1-default-pool-1b1a8331-m5nh   Ready    <none>   13m   v1.23.8-gke.1900
gke-cluster-1-default-pool-1b1a8331-m8t0   Ready    <none>   13m   v1.23.8-gke.1900



<H2>Helm Config</H2>

curl -O https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
tar -xf helm-v3.10.1-linux-amd64.tar.gz
sudo mv helm /usr/local/bin/

helm repo add stable https://kubernetes-charts.storage.googleapis.com
Error: repo "https://kubernetes-charts.storage.googleapis.com" is no longer available; try "https://charts.helm.sh/stable" instead
helm repo add stable https://charts.helm.sh/stable
helm repo list
NAME    URL                          
stable  https://charts.helm.sh/stable

<H2>nginx-ingress</H2>
kubectl create ns nginx-ingress
<pre><code>
helm upgrade --debug --install nginx-ingress stable/nginx-ingress --wait --namespace=nginx-ingress --version=1.41.3
helm uninstall nginx-ingress stable/nginx-ingress --wait --namespace=nginx-ingress
</pre></code>

Эта версия не сработала. Попробуем другую
<pre><code>
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm search repo nginx-ingress
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
nginx-stable/nginx-ingress      0.15.1          2.4.1           NGINX Ingress Controller
helm install --debug  my-nginx-ingress nginx-stable/nginx-ingress --wait --create-namespace --namespace=nginx-ingress --version=0.15.1
</pre></code>

kubectl get svc -A

После этого EXTERNAL-IP всё ещё находится в состоянии pending, что в целом логично, потому что нет никого кто бы выдал бы ему адрес.

<pre><code>
kubectl get svc -A
NAMESPACE       NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
default         kubernetes                       ClusterIP      10.96.0.1        <none>        443/TCP                      75d
kube-system     kube-dns                         ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP       75d
nginx-ingress   my-nginx-ingress-nginx-ingress   LoadBalancer   10.106.137.250   <pending>     80:32401/TCP,443:31776/TCP   111m
</pre></code>

Но с этим может запросто справиться MetalLB. Попробуем.

<pre><code>
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
</pre></code>

И после этого нах nginx ingress service получает аддресс

<pre><code>
kubectl get svc -A
NAMESPACE       NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
default         kubernetes                       ClusterIP      10.96.0.1        <none>         443/TCP                      75d
kube-system     kube-dns                         ClusterIP      10.96.0.10       <none>         53/UDP,53/TCP,9153/TCP       75d
nginx-ingress   my-nginx-ingress-nginx-ingress   LoadBalancer   10.106.137.250   172.17.255.1   80:32401/TCP,443:31776/TCP   3h10m
</pre></code>

<H2>cert-manager</H2>

<pre><code>
helm repo add jetstack https://charts.jetstack.io
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.crds.yaml
</pre></code>

1.16.1 не запустился.
<pre><code>
ensure CRDs are installed first, resource mapping not found for name: "cert-manager-controller-clusterissuers" namespace: "" from "": no matches for kind "ClusterRole" in version "rbac.authorization.k8s.io/v1beta1"
</pre></code>

Будем пользовать версию 1.10.0
<pre><code>
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
</pre></code>

Устанавливаем cert-manager 1.10.0
</pre></code>
helm upgrade --install cert-manager jetstack/cert-manager --wait --create-namespace --namespace=cert-manager --version v1.10.0
</pre></code>

kubectl get pods -n cert-manager
</pre></code>
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-69b456d85c-4rflk              1/1     Running   0          50s
cert-manager-cainjector-5f44d58c4b-wsb8l   1/1     Running   0          50s
cert-manager-webhook-566bd88f7b-hc4cv      1/1     Running   0          50s
</pre></code>

<H2>chartmuseum</H2>

kubectl create ns chartmuseum
helm repo add chartmuseum https://chartmuseum.github.io/charts
helm install --debug --wait my-chartmuseum chartmuseum/chartmuseum --version 3.9.1 --namespace=chartmuseum -f chartmuseum/values.yaml
helm ls -n chartmuseum
kubectl get secrets -n chartmuseum

curl -vvv -k https://172.17.255.1.nip.io

helm uninstall my-chartmuseum --namespace=chartmuseum
