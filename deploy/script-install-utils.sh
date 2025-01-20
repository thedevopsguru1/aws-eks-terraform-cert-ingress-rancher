#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Consider pipeline failures as errors
set -u  # Treat unset variables as an error

# Function to check for command existence
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure required commands are available
for cmd in kubectl helm; do
  if ! command_exists "$cmd"; then
    echo "Error: $cmd is not installed or not in PATH. Install it before proceeding."
    exit 1
  fi
done

# Deploy nginx ingress controller
echo "Deploying nginx ingress controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install external ingress-nginx/ingress-nginx \
  --namespace controller --create-namespace \
  --set controller.publishService.enabled=true \
  --set controller.ingressClass=nginx

# Wait for nginx ingress controller pods to be ready
echo "Waiting for nginx ingress controller pods to be ready..."
kubectl wait --namespace controller \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Deploy cert-manager
echo "Deploying cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true

# Wait for cert-manager pods to be ready
echo "Waiting for cert-manager pods to be ready..."
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=cert-manager \
  --timeout=300s

# Create Let's Encrypt ClusterIssuer
echo "Creating Let's Encrypt ClusterIssuer..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: "ypf@gmail.com"  # Replace with your email
    server: "https://acme-v02.api.letsencrypt.org/directory"
    privateKeySecretRef:
      name: "letsencrypt-prod-key"
    solvers:
      - http01:
          ingress:
            class: "nginx"
EOF

# Deploy Rancher
echo "Deploying Rancher..."
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
helm upgrade --install rancher rancher-stable/rancher \
  --namespace cattle-system --create-namespace \
  --set hostname=rancher.anaeleboo.com \
  --set bootstrapPassword=SecurePassword123! \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=ypf@gmail.com \
  --set ingress.tls.clusterIssuer=letsencrypt-prod \
  --set letsEncrypt.ingressClassName=nginx \
  --set ingress.ingressClassName=nginx \
  

# Wait for Rancher deployment to be ready
echo "Waiting for Rancher deployment to be ready..."
kubectl wait --namespace cattle-system \
  --for=condition=available deployment \
  --selector=app=rancher \
  --timeout=600s
echo "deplopy Rancher ingress"
kubectl delete ingress rancher -n cattle-system
kubectl apply -f deploy/rancher-ingress.yml
# Deployment complete
echo "Deployment complete! Access Rancher at: https://rancher.anaeleboo.com"
echo " Deploy sample app"
kubectl apply -f sample-app/