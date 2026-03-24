#!/bin/bash

# Step 1: Trigger AWS SSO login
aws sso login --profile hip13-nprd

# Step 2: Wait for 15 seconds to allow user approval
echo "Waiting 15 seconds for browser authentication..."
sleep 15

# Step 3: Run kubectl commands and store results in a file
OUTPUT_FILE="kube_resources.txt"

{
  echo "===== Kubernetes Nodes ====="
  kubectl get nodes
  echo

  echo "===== Kubernetes Namespaces ====="
  kubectl get ns
  echo

  echo "===== Deployments Across All Namespaces ====="
  kubectl get deploy -A
  echo

  echo "===== Pods Across All Namespaces ====="
  kubectl get pods -A
  echo

  echo "===== Pods in kube-system Namespace ====="
  kubectl get pods -n kube-system
  echo
} > "$OUTPUT_FILE"

echo "Basic cluster info saved to $OUTPUT_FILE"

# Step 4: Get first two pods in kube-system and log their details
PODS=( $(kubectl get pods -n kube-system -o jsonpath='{.items[*].metadata.name}') )

if [ ${#PODS[@]} -ge 2 ]; then
  FIRST=${PODS[0]}
  SECOND=${PODS[1]}

  echo "Logging details for first two kube-system pods..."
  kubectl logs "$FIRST" -n kube-system > "${FIRST}.log"
  kubectl logs "$SECOND" -n kube-system > "${SECOND}.log"

  # Step 5: Check for reconciler errors in those logs
  for POD in "$FIRST" "$SECOND"; do
    if grep -qi "reconciler" "${POD}.log"; then
      echo "⚠️ Reconciler error found in ${POD}.log"
    else
      echo "✅ No reconciler error found in ${POD}.log"
    fi
  done
fi

# Step 6: Pick one of the first three namespaces
NAMESPACES=( $(kubectl get ns -o jsonpath='{.items[*].metadata.name}') )
if [ ${#NAMESPACES[@]} -ge 3 ]; then
  SELECTED_NS=${NAMESPACES[0]}  # choose the first namespace (can randomize if desired)
  echo "Selected namespace: $SELECTED_NS"

  # Step 7: Get pods in the selected namespace
  kubectl get pods -n "$SELECTED_NS"

  # Step 8: Pick a pod from that namespace and log details
  PODS_NS=( $(kubectl get pods -n "$SELECTED_NS" -o jsonpath='{.items[*].metadata.name}') )
  if [ ${#PODS_NS[@]} -ge 1 ]; then
    RANDOM_POD=${PODS_NS[0]}  # choose the first pod (or randomize)
    echo "Selected pod: $RANDOM_POD"
    kubectl logs "$RANDOM_POD" -n "$SELECTED_NS" > "${RANDOM_POD}.log"
  fi
fi

echo "Script execution complete."
