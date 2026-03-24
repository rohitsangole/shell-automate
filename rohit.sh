#!/bin/bash

# Step 1: Trigger AWS SSO login
aws sso login --profile hip13-nprd

# Step 2: Wait for 15 seconds to allow user approval
echo "Waiting 15 seconds for browser authentication..."
sleep 15

# Step 3: Run kubectl commands and store results in a file
OUTPUT_FILE="kube_resources.txt"

{
  echo "===== Kubernetes Namespaces ====="
  kubectl get ns
  echo

  echo "===== Pods Across All Namespaces ====="
  kubectl get pods -A
  echo

  echo "===== Deployments Across All Namespaces ====="
  kubectl get deploy -A
  echo

  echo "===== Ingress Resources in kube-system Namespace ====="
  kubectl get ingress -n kube-system
  echo
} > "$OUTPUT_FILE"

echo "All results have been saved to $OUTPUT_FILE"
