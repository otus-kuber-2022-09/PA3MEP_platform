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
helm upgrade --debug --install nginx-ingress ingress-nginx/ingress-nginx --wait --create-namespace --namespace=nginx-ingress
</pre></code>

helm uninstall nginx-ingress ingress-nginx/ingress-nginx --wait --namespace=nginx-ingress

kubectl get pods -A

<pre><code>
NAMESPACE            NAME                                                     READY   STATUS    RESTARTS   AGE
default              nginx-ingress-ingress-nginx-controller-6b8c489d4-h5g2t   1/1     Running   0          10m
kube-system          coredns-565d847f94-7rzpf                                 1/1     Running   0          23m
kube-system          coredns-565d847f94-bkfhb                                 1/1     Running   0          23m
kube-system          etcd-kind-control-plane                                  1/1     Running   0          23m
kube-system          kindnet-676mj                                            1/1     Running   0          23m
kube-system          kindnet-fcn9j                                            1/1     Running   0          23m
kube-system          kindnet-p9czv                                            1/1     Running   0          23m
kube-system          kindnet-wv66l                                            1/1     Running   0          23m
kube-system          kube-apiserver-kind-control-plane                        1/1     Running   0          23m
kube-system          kube-controller-manager-kind-control-plane               1/1     Running   0          23m
kube-system          kube-proxy-5d9rr                                         1/1     Running   0          23m
kube-system          kube-proxy-8pbgt                                         1/1     Running   0          23m
kube-system          kube-proxy-bwfzz                                         1/1     Running   0          23m
kube-system          kube-proxy-s2shd                                         1/1     Running   0          23m
kube-system          kube-scheduler-kind-control-plane                        1/1     Running   0          24m
local-path-storage   local-path-provisioner-684f458cdd-8nd2x                  1/1     Running   0          23m
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