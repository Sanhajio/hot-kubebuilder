Kubernetes Cluster:
------------------

I used [kubeadm-dind-cluster](https://github.com/kubernetes-sigs/kubeadm-dind-cluster) because, IMHO, it is easier than minikube to set up when the host does not allow to spin virtual machines. Another interesting project would be to try would be [kind](https://github.com/kubernetes-sigs/kind) that does the same.

# Registry:

The cluster may use a public registry, such as Google Container Registry or Dockerhub, for local development I prefer to use a private repository, to do that in [kubeadm-dind-cluster](https://github.com/kubernetes-sigs/kubeadm-dind-cluster), run:

1. Run registry in docker on the host:
`$ docker run -d -p 5000:5000 --restart=always --name registry registry:2`

2. Run a proxy to forward each node's localhost:5000 to host's :5000 with a simple script:
```
docker ps -a -q --filter=label=mirantis.kubeadm_dind_cluster | while read container_id; do
  docker exec ${container_id} /bin/bash -c "docker rm -fv registry-proxy || true"
  # run registry proxy: forward from localhost:5000 on each node to host:5000
  docker exec ${container_id} /bin/bash -c \
    "docker run --name registry-proxy -d -e LISTEN=':5000' -e TALK=\"\$(/sbin/ip route|awk '/default/ { print \$3 }'):5000\" -p 5000:5000 tecnativa/tcp-proxy"
done
```

This workaround is taken from: [kubeadm-dind-cluster/issues/56](https://github.com/kubernetes-sigs/kubeadm-dind-cluster/issues/56#issuecomment-387463386)

This script is a subset of: [dind-cluster-v1.13.sh](https://github.com/kubernetes-sigs/kubeadm-dind-cluster/releases/download/v0.1.0/dind-cluster-v1.13.sh), It works when using [preconfigured scripts](https://github.com/kubernetes-sigs/kubeadm-dind-cluster/releases/download/v0.1.0/dind-cluster-v1.13.sh)

You better just read it, and execute the command inside it rather than executing the script itself.

# Logs:
While developping I like to have all the logs from every moving part of my system.

## Api server Logs:
To get (coredns, etcd, apiserver, kube-controller-manager, scheduler, tiller-deploy) run: `$ ./dind-logs -f (coredns, etcd, apiserver, kube-controller-manager, scheduler, tiller-deploy)`

## Container Logs

To get sloops controller logs run: `$ ./dind-logs -f sloops-controller-manager`
