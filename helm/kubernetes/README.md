site https://github.com/kubernetes/helm
wget https://kubernetes-helm.storage.googleapis.com/helm-v2.8.2-linux-amd64.tar.gz

install steps
自Kubernetes 1.6版本开始，API Server启用了RBAC授权。而目前的Tiller部署没有定义授权的ServiceAccount，这会导致访问API Server时被拒绝。我们可以采用如下方法，明确为Tiller部署添加授权。
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

请执行如下命令利用阿里云的镜像来配置 Helm
helm init --upgrade -i slpcat/tiller:v2.8.2 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
2.11安装
https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
helm init --upgrade -i slpcat/tiller:v2.11.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
#helm init --canary-image --tiller-image 
helm search
若要更新charts列表以获取最新版本
helm repo update 
若要查看在群集上安装的Charts列表
helm list 
helm ls

示例
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
helm repo add kubeless-functions-charts https://kubeless-functions-charts.storage.googleapis.com
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add openebs-charts https://openebs.github.io/charts/
helm repo add fabric8 https://fabric8.io/helm
helm repo add gitlab https://charts.gitlab.io
helm repo add jenkins-x	https://chartmuseum.build.cd.jenkins-x.io
helm repo add openfaas https://openfaas.github.io/faas-netes
helm repo add monocular https://kubernetes-helm.github.io/monocular
helm repo add rook-beta https://charts.rook.io/beta
helm repo add agones https://agones.dev/chart/stable
#helm repo add aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
helm install --name wordpress-test --set "persistence.enabled=false,mariadb.persistence.enabled=false" stable/wordpress
https://kubeapps.com/ 你可以寻找和发现已有的Charts
