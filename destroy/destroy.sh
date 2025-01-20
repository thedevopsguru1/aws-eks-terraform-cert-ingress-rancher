#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Consider pipeline failures as errors
set -u  # Treat unset variables as an error

# Function to check for command existence
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure required commands are available
for cmd in helm kubectl; do
  if ! command_exists "$cmd"; then
    echo "Error: $cmd is not installed or not in PATH. Install it before proceeding."
    exit 1
  fi
done

# Confirmation prompt
read -p "Are you sure you want to destroy all resources (y/N)? " confirm
confirm=${confirm:-N}

if [[ "$confirm" != "y" && "$confirm" != "Y" && "$confirm" != "yes" && "$confirm" != "YES"]]; then
  echo "Aborting destruction process."
  exit 0
fi

# Delete Rancher
echo "Deleting Rancher..."
helm uninstall rancher --namespace cattle-system || echo "Rancher not found or already deleted."
kubectl delete namespace cattle-system --ignore-not-found

# Delete cert-manager
echo "Deleting cert-manager..."
helm uninstall cert-manager --namespace cert-manager || echo "Cert-manager not found or already deleted."
kubectl delete namespace cert-manager --ignore-not-found

# Delete nginx ingress controller
echo "Deleting nginx ingress controller..."
helm uninstall external --namespace controller || echo "Ingress-nginx not found or already deleted."
kubectl delete namespace controller --ignore-not-found

# Delete Let's Encrypt ClusterIssuer
echo "Deleting Let's Encrypt ClusterIssuer..."
kubectl delete clusterissuer letsencrypt-prod --ignore-not-found

# Final cleanup
echo "Cleaning up residual resources..."
kubectl delete secret letsencrypt-prod-key --ignore-not-found -n cert-manager
kubectl get all --all-namespaces

# Completed
echo "All resources will be destroyed."
echo "Do you want to delete the EKS cluster? (yes/no)"
read -r destroy_eks

if [ "$destroy_eks" = "yes" ]; then
    echo "Destroying the EKS cluster..."
    # Add the specific terraform destroy command for EKS cluster if needed
    terraform destroy -auto-approve
else
    echo "EKS cluster will not be destroyed."
fi

echo "You may want to delete the S3 bucket and DynamoDB table used by Terraform."
echo "Also, remember to delete the Route 53 hosted zone if you created one."
echo "Finally, you may want to delete the IAM user and access keys created for Terraform."

# Terraform destroy command to delete everything else
terraform destroy -auto-approve

echo "All resources destroyed."

