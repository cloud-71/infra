## Ansible

Once we have [provisioned our OpenStack resources using Heat](../heat), we can
use Ansible to set up our Kubernetes cluster.

0. Connect to the unimelb VPN (you can use the Cisco AnyConnect app instead)

       openconnect remote.unimelb.edu.au/student

1. Update `inventory/hosts.ini` with the IP addresses by running

       inventory/update_hosts.py

2. Run the ansible playbook

       ansible-playbook site.yml -i inventory/hosts.ini --key-file ~/.ssh/id_group71

3. Copy the Kubernetes configuration from the cloud to your local machine

       scp -i ~/.ssh/id_group71 debian@<master_ip>:/etc/rancher/k3s/k3s.yaml ~/group71_kubeconfig

4. Edit kubeconfig to change IP to master IP

       sed --in-place 's/127.0.0.1/<master_ip>/' ~/group71_kubeconfig

5. export kubeconfig env var

       export KUBECONFIG="${HOME}/group71_kubeconfig"
