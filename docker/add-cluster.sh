#!/bin/sh

# Log in to Argo CD
echo "Logging in to Argo CD..."
argocd login $ARGOCD_SERVER --username=$ARGOCD_USERNAME --password=$ARGOCD_PASSWORD --insecure
echo "Successfully logged in to Argo CD!"

# Read the clusters file and iterate over each line
while IFS=':' read -r CLUSTER_NAME CLUSTER_SERVER; do
  # Trim whitespace from the cluster name and server
  CLUSTER_NAME=$(echo "$CLUSTER_NAME" | tr -d '[:space:]')
  CLUSTER_SERVER=$(echo "$CLUSTER_SERVER" | tr -d '[:space:]')

  # Log in to the cluster using the provided token and server URL
  echo "Logging in to cluster $CLUSTER_NAME..."
  oc login --token=$CLUSTER_TOKEN --server=$CLUSTER_SERVER --insecure-skip-tls-verify=true
  echo "Successfully logged in to cluster $CLUSTER_NAME!"

  # Get the current context of the cluster
  CLUSTER_CONTEXT=$(kubectl config view --minify --output 'jsonpath={.current-context}' --kubeconfig=/.kube/config)
  echo "Cluster Context: $CLUSTER_CONTEXT"  # Print cluster context to stdout

  # Add the cluster using argocd cluster add command
  echo "Adding cluster $CLUSTER_NAME to Argo CD..."
  argocd cluster add "$CLUSTER_CONTEXT" --name "$CLUSTER_NAME" --yes
  echo "Cluster $CLUSTER_NAME added successfully!"
done < clusters
