# aws-eks-with-terraform

### Connect to an EKS cluster
```
aws eks update-kubeconfig --region region-code --name my-cluster
```
#### For example: 
```
aws eks update-kubeconfig --region us-east-2 --name staging-demo
```
## Use Longhorn Storage Class
### Manually install iscsi on each server manually

```
#!/bin/bash

# Update the system
sudo yum update -y

# Install iSCSI utilities
sudo yum install -y iscsi-initiator-utils

# Enable and start the iSCSI service
sudo systemctl enable iscsid
sudo systemctl start iscsid

# Optional: Install additional utilities if needed
#yum install -y vim git

# Ensure the system is fully updated and packages installed
sudo yum clean all

# Reboot the instance 
```

### Comment out the 16 before running apply.
