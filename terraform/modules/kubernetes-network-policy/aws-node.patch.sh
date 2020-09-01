#!/usr/bin/env bash

set -euo pipefail

# don't import the crd. Helm cant manage the lifecycle of it anyway.
for kind in daemonSet clusterRole clusterRoleBinding serviceAccount; do
  echo "setting annotations and labels on $kind/aws-node"
  kubectl -n kube-system annotate --overwrite $kind aws-node meta.helm.sh/release-name=aws-vpc-cni
  kubectl -n kube-system annotate --overwrite $kind aws-node meta.helm.sh/release-namespace=kube-system
  kubectl -n kube-system label --overwrite $kind aws-node app.kubernetes.io/managed-by=Helm
done
