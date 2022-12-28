<H1>ДЗ день 18. Хранилище секретов для приложений. Vault</H1>
<H2>Подготовка</H2>

Имеет кластер 1 мастер и 2 нода

<pre><code>
kubectl get nodes
NAME           STATUS   ROLES                  AGE     VERSION
kubik-master   Ready    control-plane,master   10m     v1.23.15
kubik-node-1   Ready    <none>                 9m6s    v1.23.15
kubik-node-2   Ready    <none>                 8m57s   v1.23.15
</pre></code>

Состояние подов

<pre><code>
kubectl get pods -A
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   coredns-bd6b6df9f-httbv                1/1     Running   0          11m
kube-system   coredns-bd6b6df9f-ndj9n                1/1     Running   0          11m
kube-system   etcd-kubik-master                      1/1     Running   0          11m
kube-system   kube-apiserver-kubik-master            1/1     Running   0          11m
kube-system   kube-controller-manager-kubik-master   1/1     Running   0          11m
kube-system   kube-proxy-hcvnm                       1/1     Running   0          11m
kube-system   kube-proxy-vzh9h                       1/1     Running   0          9m48s
kube-system   kube-proxy-wt97g                       1/1     Running   0          9m57s
kube-system   kube-scheduler-kubik-master            1/1     Running   0          11m
kube-system   weave-net-2lmr6                        2/2     Running   0          7m29s
kube-system   weave-net-lbt8p                        2/2     Running   0          7m29s
kube-system   weave-net-zjwm8                        2/2     Running   0          7m29s
</pre></code>

<H2>Инсталляция hashicorp vault HA в k8s</H2>

kubectl apply -f consul-storage-class.yamlcd

git clone https://github.com/hashicorp/consul-k8s.git

cd consul-k8s/charts/consul
helm install consul .

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm upgrade --install consul hashicorp/consul

git clone https://github.com/hashicorp/vault-helm.git

<H2>Установим vault</H2>
<pre><code>
cd vault-helm/
helm install vault .
</pre></code>


helm status vault
<pre><code>
NAME: vault
LAST DEPLOYED: Tue Dec 27 18:03:27 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!
</pre></code>