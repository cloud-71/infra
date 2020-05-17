# infra

Deploy the necesssary cloud infrastructure to run a CouchDB cluster, the
Twitter harvester, the AURIN downloader and the web app.

## Prerequisites

1. Install [JQ](https://stedolan.github.io/jq/):

       brew install jq

2. Ensure you have the openstack CLI and heat plugin:

       pip install python-openstackclient python-heatclient

3. Ensure you have ansible and kubectl installed

       brew install ansible kubectl

4. Ensure you have either Cisco AnyConnect Secure Mobility client or
   openconnect (better):

       brew install openconnect

## Deploy

1. [Provision the infrastructure using OpenStack Heat](./heat)

2. [Set up a Kubernetes cluster using Ansible](./ansible)

3. [Deploy the Kubernetes manifests using kubectl](./kubernetes)
