#!/bin/bash

# Assumptions: 
# - The following are pre-installed: python-openstackclient, python-heatclient, awk
# - The host is connected to the Unimelb VPN

set -euo pipefail

stack_name=$1
key_file="$HOME/.ssh/id_group71"
from_task="Copy Kubernetes config from cloud to local machine"

# Copy the private key to local ssh keystore
openstack stack output show -f json "$stack_name" private_key | jq --raw-output '.output_value' > "$key_file"
chmod 600 "$key_file"


# Update the ansible hosts file
ansible/inventory/update_hosts.py

# Run the ansible playbook
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ansible/site.yml \
                                              -i ansible/inventory/hosts.ini \
                                              --key-file "$key_file" \
                                              --start-at-task "$from_task" \
                                              --limit "master"
