kubectl create -k "github.com/ray-project/kuberay/ray-operator/config/crd?ref=v0.3.0&timeout=90s"
helm upgrade kuberay-operator ./kuberay-operator/ --install --namespace kuberay --create-namespace
helm upgrade redis ./redis/ --install --namespace kuberay --create-namespace
kubectl apply -f ./autoscaler.yml --namespace kuberay
