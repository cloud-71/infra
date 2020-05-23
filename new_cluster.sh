#!/bin/bash

# Assumptions: 
# - The following are pre-installed: python-openstackclient, python-heatclient, awk
# - The host is connected to the Unimelb VPN

set -euo pipefail

stack_name=$1
target_group=$2
key_file="$HOME/.ssh/id_group71"

# Check for existing clusters
old_stack_names=$(openstack stack list -f json | jq --raw-output '.[]."Stack Name"')

# Remove existing clusters
if [[ -z "$old_stack_names" ]]
then
      echo "No current running cluster"
else
      echo "Deleting current running clusters: $old_stack_names"
      echo "$old_stack_names" | xargs openstack stack delete --wait
fi

# Create new cluster
echo "Creating the following stack: $stack_name"
openstack stack create --wait --template heat/cluster.yaml --environment heat/cluster.$target_group.params.yaml "$stack_name"

# Copy the private key to local ssh keystore
openstack stack output show -f json "$stack_name" private_key | jq --raw-output '.output_value' > "$key_file"
chmod 600 "$key_file"

# Update the ansible hosts file
ansible/inventory/update_hosts.py

# Run the ansible playbook
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ansible/site.yml -i ansible/inventory/hosts.ini --key-file "$key_file"
