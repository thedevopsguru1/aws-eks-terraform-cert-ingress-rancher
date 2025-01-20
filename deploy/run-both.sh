# Function to check for command existence
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure required commands are available
for cmd in terraform kubectl; do
  if ! command_exists "$cmd"; then
    echo "Error: $cmd is not installed or not in PATH. Install it before proceeding."
    exit 1
  fi
done

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate

# Apply Terraform configuration
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Get Kubernetes cluster credentials
echo "Getting Kubernetes cluster credentials..."
aws eks update-kubeconfig --region us-east-2 --name staging-demo
echo "Waiting for a minute"
sleep 20
bash deploy/script-install-utils.sh
