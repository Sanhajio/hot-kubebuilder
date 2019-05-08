Skaffold Dev Kubebuilder
------------------------

Fast development iteration of a Kubernetes API using Kubebuilder with Skaffold.

Trying Skaffold hot reload feature developping Kubernetes Controllers.

# Pre-requisites

Getting started with the projects assumes you have:

- Kubernetes Cluster
- [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)
- [Kustomize](https://github.com/kubernetes-sigs/kustomize/)
- [Skaffold](https://github.com/GoogleContainerTools/skaffold)
- Docker

# Quick Start:

If everything (GOPATH, dep, Skaffold, Docker local registry) is set up right, run:

`$ skaffold dev`
`$ skaffold dev`

This should compile the code, create the docker image and deploy it to the kubernetes cluster.

Go make changes to the code within `pkg/controller/sloop/sloop_controller.go` skaffold would automatically detect the change and build a new image and deploy it to the cluster.

skaffold prints containers logs, you can get the logs by running:
`$ kubectl -n sloops-system logs -f -c manager sloops-controller-manager-0`

You can manually trigger changes to skaffold, using:
`$ skaffold dev --trigger manual`

# Cluster

To deploy Kubernetes cluster, I used [kubeadm-dind-cluster](https://github.com/kubernetes-sigs/kubeadm-dind-cluster), helpers can be found under the cluster directory.
