#!/bin/bash


DEFAULT_DIND_LABEL='mirantis.kubeadm_dind_cluster_runtime'

usage() {
echo "Usage: $0"
echo "    -f      (Required) Follow logs for pod: (coredns, etcd, apiserver, kube-controller-manager, sloops-controller-manager, scheduler, tiller-deploy)"
echo "    -m      (Optional) Cluster Master Name set up during creation of the dind cluster"
echo "    -c      (Optional) Cluster Context Name set up during creation of the dind cluster"
echo "    -d      (Optional) Cluster Dind Label set up during creation of the dind cluster"
echo "    -i      (Optional) Cluster Id set up during creation of the dind cluster"
echo "    -h      Help, print this help message"
exit 1;
}

while getopts ":f:m:c:d:i:h" o; do
  case "${o}" in
    f)
      FILTER=${OPTARG}
      ;;
    m)
      MASTER_NAME=${OPTARG}
      ;;
    c)
      CONTEXT_NAME=${OPTARG}
      ;;
    d)
      DIND_LABEL=${OPTARG}
      ;;
    i)
      CLUSTER_ID=${OPTARG}
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z ${FILTER} ]]; then
  echo "Missing pod to follow: -f"
  usage
  exit 1
fi

if [[ -z ${CONTEXT_NAME} ]]; then
  CONTEXT_NAME="dind"
fi

if [[ -z ${MASTER_NAME} ]]; then
  MASTER_NAME="kube-master"
fi

if [[ -z ${DIND_LABEL} ]]; then
  DIND_LABEL=${DEFAULT_DIND_LABEL}
fi

if [[ -z ${CLUSTER_ID} ]]; then
  CLUSTER_ID="0"
fi

DEFAULT_DIND_LABEL='mirantis.kubeadm_dind_cluster_runtime'

logs() {
  set +e
  master_name=$MASTER_NAME
  ctx=$CONTEXT_NAME
  FILTER=$1
  docker exec "$master_name" kubectl get pods --all-namespaces \
          -o go-template='{{range $x := .items}}{{range $x.spec.containers}}{{$x.spec.nodeName}}{{" "}}{{$x.metadata.namespace}}{{" "}}{{$x.metadata.name}}{{" "}}{{.name}}{{"\n"}}{{end}}{{end}}' |
    while read node ns pod container; do
      if [[ ${node}-${ns}-${pod}-${container} == *"$FILTER"* ]]; then
        echo "pod-${node}-${ns}-${pod}--${container}.log"
        docker exec "$master_name" kubectl logs -f -n "${ns}" -c "${container}" "${pod}"
      fi
    done
}

if [[ $FILTER == "sloops-controller-manager" ]]; then
    FILTER="sloops-controller-manager-0-manager"
fi

logs $FILTER
