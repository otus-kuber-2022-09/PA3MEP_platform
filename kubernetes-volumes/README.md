<H1>ДЗ день 5</H1>
<H2>Настраиваем Kind</H3>

kind create cluster --config kind-config.yaml
Создаётся кластер с одним control-plainом и тремя нодами

kubectl get nodes

<H2>Запускаем StatefulSet и Service</H2>
kibectl apply -f minio-statefulset.yaml
kubectl apply -f minio-headless-service.yaml

Смотрим что получилось

kubectl get statefulsets
NAME    READY   AGE
minio   1/1     20m

kubectl get pvc
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-minio-0   Bound    pvc-e3e9f096-2246-46c5-9428-57046bd53b7a   10Gi       RWO            standard       20m

kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
pvc-e3e9f096-2246-46c5-9428-57046bd53b7a   10Gi       RWO            Delete           Bound    default/data-minio-0   standard                20m

kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP    22m
minio        ClusterIP   None         <none>        9000/TCP   19m

<H2>Secrets</H2>
Создаём Secret и назовём его minio-secret. Перенесём в него MINIO_ACCESS_KEY и MINIO_SECRET_KEY. Выглядит это примерно так:

<pre><code>
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: minio-secret
  namespace: default
stringData:
  MINIO_ACCESS_KEY: minio
  MINIO_SECRET_KEY: minio123
</pre></code>

И теперь заменим значения MINIO_ACCESS_KEY и MINIO_SECRET_KEY на ссылки на наш Secret.

<pre><code>
env:
    - name: MINIO_ACCESS_KEY
        valueFrom:
        secretKeyRef:
            name: minio-secret
            key: MINIO_ACCESS_KEY
    - name: MINIO_SECRET_KEY
        valueFrom:
        secretKeyRef:
            name: minio-secret
            key: MINIO_SECRET_KEY
</pre></code>