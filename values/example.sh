#!/bin/bash

# Update the system
yum update -y

# Install iSCSI utilities
yum install -y iscsi-initiator-utils

# Enable and start the iSCSI service
systemctl enable iscsid
systemctl start iscsid

# Optional: Install additional utilities if needed
yum install -y vim git

# Ensure the system is fully updated and packages installed
yum clean all

# Reboot the instance if necessary (not typically required)
# reboot
