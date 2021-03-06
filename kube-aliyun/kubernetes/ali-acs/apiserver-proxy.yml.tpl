apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
---
apiVersion: v1
data:
  nginx.conf: |
    error_log stderr notice;
    worker_processes auto;
    events {
      multi_accept on;
      use epoll;
      worker_connections 1024;
    }

    stream {
        upstream kube_apiserver {
            least_conn;

        }

        server {
            listen        0.0.0.0:6443;
            proxy_pass    kube_apiserver;
            proxy_timeout 10m;
            proxy_connect_timeout 1s;
        }
    }
kind: ConfigMap
metadata:
  labels:
    app: api-proxy
  name: api-proxy
  namespace: kube-system

---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: api-proxy
  namespace: kube-system
  labels:
    tier: node
    app: api-proxy
spec:
  template:
    metadata:
      labels:
        tier: node
        app: api-proxy
    spec:
      hostNetwork: true
      nodeSelector:
        beta.kubernetes.io/arch: amd64
#      tolerations:
#      - key: node-role.kubernetes.io/master
#        operator: Exists
#        effect: NoSchedule
      serviceAccountName: admin
      restartPolicy: Always
      containers:
      - name: api-proxy
        image: registry-vpc.cn-beijing.aliyuncs.com/acs/nginx:1.13.3
        command: [ "nginx","-g","daemon off;" ,"-c", "/etc/kube-api-proxy/nginx.conf"]
        securityContext:
          privileged: true
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: kube
          mountPath: /etc/kubernetes/
        - name: api-config
          mountPath: /etc/kube-api-proxy/
      volumes:
      - name: kube
        hostPath:
          path: /etc/kubernetes/
      - configMap:
          defaultMode: 420
          name: api-proxy
        name: api-config
