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

<H2>MySQL контроллер</H2>

sudo pip install kopf kubernetes jinja2
kopf run mysql-operator.py

<pre><code>
[2022-12-05 09:24:47,667] kopf._core.engines.a [INFO    ] Initial authentication has been initiated.
[2022-12-05 09:24:47,678] kopf.activities.auth [INFO    ] Activity 'login_via_client' succeeded.
[2022-12-05 09:24:47,678] kopf._core.engines.a [INFO    ] Initial authentication has finished.
[2022-12-05 09:25:36,096] kopf.objects         [WARNING ] [default/mysql-instance] Patching failed with inconsistencies: (('remove', ('status',), {'kopf': {'dummy': '2022-12-05T07:25:36.083874'}}, None),)
[2022-12-05 09:25:36,291] kopf.objects         [INFO    ] [default/mysql-instance] Handler 'mysql_on_create' succeeded.
[2022-12-05 09:25:36,291] kopf.objects         [INFO    ] [default/mysql-instance] Creation is processed: 1 succeeded; 0 failed.
</pre></code>

<pre><code>
kubectl delete mysqls.otus.homework mysql-instance
kubectl delete deployments.apps mysql-instance
kubectl delete pvc mysql-instance-pvc
kubectl delete pv mysql-instance-pv
kubectl delete svc mysql-instance
</pre></code>

Добавляем on.delete handler в наш оператор и перезапускаем

<pre><code>
kopf run mysql-operator.py
</pre></code>

Все объекты создаются как и до этого, но теперь попробуем удалить mysql-instance

<pre><code>
kubectl delete mysqls.otus.homework mysql-instance
mysql.otus.homework "mysql-instance" deleted
</pre></code>

Посмотрим на состояние кластера

<pre><code>
kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   48d

kubectl get pv
No resources found in default namespace.

kubectl get pvc
No resources found in default namespace.
</pre></code>

Чисто.

Добавляем в оператор поддержку Backup/Restore функционала и перезапускаем

<pre><code>
kopf run mysql-operator.py
kubectl apply -f deploy/cr.yml
</pre></code>

<pre><code>
kubectl get all -n default
NAME                                   READY   STATUS    RESTARTS   AGE
pod/mysql-instance-6db47985f-t85hf     1/1     Running   0          16s
pod/restore-mysql-instance-job-gfqfj   0/1     Pending   0          16s

NAME                     TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/kubernetes       ClusterIP   10.96.0.1    <none>        443/TCP    48d
service/mysql-instance   ClusterIP   None         <none>        3306/TCP   16s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mysql-instance   1/1     1            1           16s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/mysql-instance-6db47985f   1         1         1       16s

NAME                                   COMPLETIONS   DURATION   AGE
job.batch/restore-mysql-instance-job   0/1           16s        16s

kubectl get pvc -n default
NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-instance-pvc   Bound    pvc-90e70c2f-7ed5-488c-907f-bee2eb72ade0   1Gi        RWO            standard       72s
</pre></code>

Заполняем базу

export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
kubectl exec -it $MYSQLPOD -- mysql -u root -potuspassword -e "CREATE TABLE test ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES ( null, 'some data' );" otus-database 
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES (null, 'some data-2' );" otus-database

kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+

Удалим mysql-instance:

kubectl delete mysqls.otus.homework mysql-instance

kubectl get jobs.batch
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    0/1           29s        29s

Пересоздадим MySQL

kubectl apply -f deploy/cr.yml

Проверим состояние базы

export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+


