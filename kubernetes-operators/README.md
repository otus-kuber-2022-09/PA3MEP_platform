<H1>ДЗ день 10. Операторы, CustomResourceDefinition</H1>
Платформа

<pre><code>
minikube v1.27.0 on Ubuntu 22.04
Kubernetes 1.25.0 has a known issue with resolv.conf. minikube is using a workaround that should work for most use cases.
</pre></code>

kubectl apply -f deploy/crd.yml

kubectl apply -f deploy/cr.yml

kubectl get crd
<pre><code>
NAME                   CREATED AT
mysqls.otus.homework   2022-12-01T16:37:42Z
</pre></code>

kubectl get mysqls.otus.homework
<pre><code>
NAME             AGE
mysql-instance   2m18s
</pre></code>

kubectl describe mysqls.otus.homework mysql-instance

<pre><code>
Name:         mysql-instance
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  otus.homework/v1
Kind:         MySQL
Metadata:
  Creation Timestamp:  2022-12-01T16:41:54Z
  Generation:          1
  Managed Fields:
    API Version:  otus.homework/v1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .:
          f:kubectl.kubernetes.io/last-applied-configuration:
      f:spec:
        .:
        f:database:
        f:image:
        f:password:
        f:storage_size:
      f:usless_data:
    Manager:         kubectl-client-side-apply
    Operation:       Update
    Time:            2022-12-01T16:41:54Z
  Resource Version:  10411
  UID:               8a665e6d-fda3-4ff1-bb10-b7f7fb0fa9f2
Spec:
  Database:      otus-database
  Image:         mysql:5.7
  Password:      otuspassword
  storage_size:  1Gi
usless_data:     useless info
Events:          <none>
</pre></code>


sudo pip install kopf kubernetes jinja2
kopf run mysql-operator.py