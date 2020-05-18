## Ansible

Once we have [provisioned our OpenStack resources using Heat](../heat), we can
use Ansible to set up our Kubernetes cluster.

0. Connect to the unimelb VPN (you can use the Cisco AnyConnect app instead)

       openconnect remote.unimelb.edu.au/student

1. Update `inventory/hosts.ini` with the IP addresses by running

       inventory/update_hosts.py

2. Run the ansible playbook

       ansible-playbook site.yml -i inventory/hosts.ini --key-file ~/.ssh/id_group71


3.  Copy the kubeconfig export line from the ansible debug output and execute it

       export KUBECONFIG="${HOME}/group71_kubeconfig"
