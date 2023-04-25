# The distributed test runner
## build with [ray.io](Ray), runs on kubernetes

This project contains 2 part:

1. The ray cluster environment [Part 1](#part-1-the-ray-cluster)
2. The testing suits, for monitoring and collect results [Part 2](#part-2-the-testing-suit)

—

# Part 1: the ray cluster

## 1. create project, and install dependency

At the time i writting this, the support for python 3.10 on windows is not delivered. So we had to stuck on python 3.9

```bash
conda create --name distriTester python=3.9
pip install "ray[default]"
```

install `kubectl` on whatever platform you're using [Install Tools | Kubernetes](https://kubernetes.io/docs/tasks/tools/)

## 2. config ray cluster and autoscaler

also our redis for simple storage
```bash
cd k8s
sh setup.sh
```

```bash
# before we run our code, we need map the ray-cluster port to local
kubectl port-forward service/raycluster-autoscaler-head-svc 8265:8265
```