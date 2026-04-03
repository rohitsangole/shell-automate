#!/bin/bash

# Step 0: Ask user for AWS profile name
read -p "Enter AWS profile name: " PROFILE

# Step 1: Trigger AWS SSO login with user-provided profile
aws sso login --profile "$PROFILE"

# Step 2: Wait for 15 seconds to allow user approval
echo "Waiting 15 seconds for browser authentication..."
sleep 15

# Step 3: Run aws eks command for the selected profile
case "$PROFILE" in
  hieep-nprd)
    aws eks --profile "$PROFILE" # Placeholder for hip13-nprd
    ;;
  profile2)
    aws eks --profile "$PROFILE" # Placeholder for profile2
    ;;
  profile3)
    aws eks --profile "$PROFILE" # Placeholder for profile3
    ;;
  profile4)
    aws eks --profile "$PROFILE" # Placeholder for profile4
    ;;
  profile5)
    aws eks --profile "$PROFILE" # Placeholder for profile5
    ;;
  profile6)
    aws eks --profile "$PROFILE" # Placeholder for profile6
    ;;
  profile7)
    aws eks --profile "$PROFILE" # Placeholder for profile7
    ;;
  profile8)
    aws eks --profile "$PROFILE" # Placeholder for profile8
    ;;
  profile9)
    aws eks --profile "$PROFILE" # Placeholder for profile9
    ;;
  profile10)
    aws eks --profile "$PROFILE" # Placeholder for profile10
    ;;
  profile11)
    aws eks --profile "$PROFILE" # Placeholder for profile11
    ;;
  profile12)
    aws eks --profile "$PROFILE" # Placeholder for profile12
    ;;
  profile13)
    aws eks --profile "$PROFILE" # Placeholder for profile13
    ;;
  profile14)
    aws eks --profile "$PROFILE" # Placeholder for profile14
    ;;
  *)
    echo "Unknown profile: $PROFILE"
    ;;
esac

# Step 4: Run kubectl commands and store results in a file
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

# Step 5: Get first two pods in kube-system and log their details
PODS=( $(kubectl get pods -n kube-system -o jsonpath='{.items[*].metadata.name}') )

if [ ${#PODS[@]} -ge 2 ]; then
  FIRST=${PODS[0]}
  SECOND=${PODS[1]}

  echo "Logging details for first two kube-system pods..."
  kubectl logs "$FIRST" -n kube-system > "${FIRST}.log"
  kubectl logs "$SECOND" -n kube-system > "${SECOND}.log"

  # Step 6: Check for reconciler or ERROR keywords in those logs
  for POD in "$FIRST" "$SECOND"; do
    if grep -Eqi "reconciler|ERROR" "${POD}.log"; then
      echo " Issue found in ${POD}.log (contains 'reconciler' or 'ERROR')"
    else
      echo " No reconciler or ERROR keywords found in ${POD}.log"
    fi
  done
fi

# Step 7: Pick one of the first three namespaces
NAMESPACES=( $(kubectl get ns -o jsonpath='{.items[*].metadata.name}') )
if [ ${#NAMESPACES[@]} -ge 3 ]; then
  SELECTED_NS=${NAMESPACES[0]}  # choose the first namespace (can randomize if desired)
  echo "Selected namespace: $SELECTED_NS"

  {
    echo "===== Pods in Selected Namespace: $SELECTED_NS ====="
    kubectl get pods -n "$SELECTED_NS"
    echo
  } >> "$OUTPUT_FILE"

  # Step 8: Pick a pod from that namespace and log details
  PODS_NS=( $(kubectl get pods -n "$SELECTED_NS" -o jsonpath='{.items[*].metadata.name}') )
  if [ ${#PODS_NS[@]} -ge 1 ]; then
    RANDOM_POD=${PODS_NS[0]}  # choose the first pod (or randomize)
    echo "Selected pod: $RANDOM_POD"
    kubectl logs "$RANDOM_POD" -n "$SELECTED_NS" > "${RANDOM_POD}.log"
  fi
fi

echo "Script execution complete."
