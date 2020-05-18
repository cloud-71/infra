#!/bin/bash

# Assumptions: 
# - The following are pre-installed: python-openstackclient, python-heatclient, awk
# - The host is connected to the Unimelb VPN

# Check for existing cluster
cluster_name=$(openstack stack list | awk -F'|' ' NR > 3 && !/^+--/ { print $3} ')
cluster_name_trimmed="$(echo -e "${cluster_name}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

# Remove existing cluster
if [ -z "$cluster_name" ]
then
      echo "No current running cluster"
else
      echo "Found current running cluster: $cluster_name_trimmed"
      echo "Deleting cluster"
      openstack stack delete $cluster_name_trimmed
fi

# Create new cluster
export STACK_NAME=$1
echo 'Creating the following stack:'
echo ${STACK_NAME}
openstack stack create --template heat/cluster.yaml --environment heat/cluster.params.yaml ${STACK_NAME}

# Wait two minutes for stack creation to complete
echo 'Waiting for stack to be created'
sleep 180

# Copy the private key to local ssh keystore
openstack stack output show -f json ${STACK_NAME} private_key | jq -r '.output_value' > ${HOME}/.ssh/id_group71
chmod 600 ~/.ssh/id_group71

# Update the ansible hosts file
python3 ansible/inventory/update_hosts.py

# Run the ansible playbook
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook ansible/site.yml -i ansible/inventory/hosts.ini --key-file ~/.ssh/id_group71

echo 'DONE'