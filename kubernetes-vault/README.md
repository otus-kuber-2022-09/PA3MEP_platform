<H1>ДЗ день 18. Хранилище секретов для приложений. Vault</H1>
<H2>Подготовка</H2>

Имеет кластер 1 мастер и 2 нода

<pre><code>
kubectl get nodes
NAME        STATUS   ROLES           AGE   VERSION
kube-mgr    Ready    control-plane   35d   v1.25.4
kube-min1   Ready    <none>          14m   v1.25.4
kube-min2   Ready    <none>          14m   v1.25.4
</pre></code>

Состояние подов

<pre><code>
kubectl get pods -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS      AGE
kube-system   coredns-58ff9bfdfc-fqjk5           1/1     Running   0             35d
kube-system   coredns-58ff9bfdfc-zhvch           1/1     Running   0             35d
kube-system   etcd-kube-mgr                      1/1     Running   2 (42m ago)   35d
kube-system   kube-apiserver-kube-mgr            1/1     Running   2 (42m ago)   35d
kube-system   kube-controller-manager-kube-mgr   1/1     Running   2 (42m ago)   35d
kube-system   kube-proxy-gq5qz                   1/1     Running   0             14m
kube-system   kube-proxy-nnxw7                   1/1     Running   0             14m
kube-system   kube-proxy-qz6w8                   1/1     Running   2 (42m ago)   35d
kube-system   kube-scheduler-kube-mgr            1/1     Running   2 (42m ago)   35d
kube-system   weave-net-rcpfz                    2/2     Running   0             12m
kube-system   weave-net-rfd8c                    2/2     Running   0             12m
kube-system   weave-net-x84bc                    2/2     Running   0             12m
</pre></code>

<H2>Инсталляция hashicorp vault HA в k8s</H2>

kubectl apply -f consul-storage-class.yaml

git clone https://github.com/hashicorp/consul-k8s.git
git clone https://github.com/hashicorp/vault-helm.git

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