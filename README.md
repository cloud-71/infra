# infra
The ansible stuff and CouchDB Kubernetes template

## Prerequisites

1. Install [JQ](https://stedolan.github.io/jq/):

    brew install jq

2. Ensure you have the openstack CLI and heat plugin:

    pip install python-openstackclient python-heatclient

3. Ensure you have ansible installed

    brew install ansible

4. Ensure you have either Cisco AnyConnect Secure Mobility client or
   openconnect (better):

    brew install openconnect

## Heat

We are using [OpenStack Heat](https://wiki.openstack.org/wiki/Heat) to
provision our infrastructure.  You can refer to the
[example templates](https://github.com/openstack/heat-templates) and
[Resource Type reference](https://docs.openstack.org/heat/train/template_guide/openstack.html).

1. [Obtain password](https://dashboard.cloud.unimelb.edu.au/settings/reset-password/) from MRC dashboard (reset is fine).

2. [Download](https://dashboard.cloud.unimelb.edu.au/project/api_access/openrc/) and source the OpenStack RC file, when prompted enter password from step 1

    source ~/Downloads/unimelb-comp90024-2020-grp-71-openrc

3. Delete any previous stacks

    openstack stack list
    openstack stack delete <name>

4. If it get stuck, delete any remaining instances:

    openstack server list
    openstack server delete <id>

5. Create a new stack

    openstack stack create --template cluster.yaml --environment cluster.params.yaml <name> 

6. Get the IP addresses

    openstack stack output show -f json <name> nodes_private_ips | jq -r '.output_value[][0]'

7. Copy the private key

    openstack stack output show -f json <name> private_key | jq -r '.output_value' > ~/.ssh/id_group71
    chmod 600 ~/.ssh/id_group71

## Ansible

Once we have provisioned our OpenStack resources using Heat, we can use Ansible
to set up our Kubernetes cluster.

0. Connect to the unimelb VPN (you can use the Cisco AnyConnect app instead)

    openconnect remote.unimelb.edu.au/student

1. Update `inventory/hosts.ini` with the IP addresses from step 6 above,
   choosing one of them as the master and the remaining 3 as nodes.

2. Run the ansible playbook

    ansible-playbook site.yml -i inventory/hosts.ini --key-file ~/.ssh/id_group71

3. Copy the Kubernetes configuration from the cloud to your local machine.

    scp -i ~/.ssh/id_group71 debian@<master_ip>:/etc/rancher/k3s/k3s.yaml ~/group71_kubeconfig

4. Edit kubeconfig to change IP to master IP

    sed --in-place 's/127.0.0.1/<master_ip>/' ~/group71_kubeconfig

5. export kubeconfig env var

    export KUBECONFIG="${HOME}/group71_kubeconfig"


## K3D Setup Instructions

Set up a dev cluster on your local machine using

    brew install k3d
    k3d create --publish 5984:80 --workers=3
    export KUBECONFIG=$(k3d get-kubeconfig)

Install CouchDB using

    kubectl apply -f kubernetes/couchdb.yml

Monitor progress:

    kubectl --namespace=kube-system get events --watch

Once it settles down, check whether it worked:

    kubectl get all

CouchDB can be contacted using

    curl -H "Host: chart-example.local" localhost:5984/


Get CouchDB admin password:

    kubectl get secret couchdb-couchdb -o go-template='{{ .data.adminPassword }}' | base64 --decode


Make a GET command to couchdb that requires admin access (replace generated admin secret):

    curl -X GET -H "Host: chart-example.local" http://admin:dZi2nSHIyPdxfallYOzp@127.0.0.1:5984/_all_dbs
