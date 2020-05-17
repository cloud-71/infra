# Kubernetes manifests

We are using kubectl to deploy our Kubernetes resources, k3d to test changes
locally on our computers, and [Kustomize][kustomize] to adapt our manifests for
local development and cloud deployment. You can install them using:

    brew install k3d kustomize kubectl

The [base](./base) directory contains the shared resources that are useful locally as well as in the cloud, e.g. our web app, Twitter harvester, AURIN downloader, and CouchDB cluster.

The [cloud](./cloud) directory extends these shared resources with some others that only make sense on the Melbourne Research Cloud, e.g. the Cinder storage provider plugin that is used to attach persistent volumes and the Melbourne Uni proxy pod preset. It also patches the CouchDB helm chart to enable cloud-specific features.

The [local](./local) directory references the shared resources, and patches the CouchDB deployment to add an ingress for ease of development.

## Deploy to the Melbourne Research Cloud

First, ensure you have set up your `KUBECONFIG` to point to the K3s cluster on
Melbourne Research Cloud that was created [using Ansible](../ansible). Then,
you can run the following command to deploy everything:

    kustomize build cloud | kubectl apply -f -

## K3D Setup Instructions

Set up a dev cluster on your local machine using

    k3d create --publish 5984:5984 --server-arg=disable=traefik
    export KUBECONFIG=$(k3d get-kubeconfig)

Deploy the manifests using

    kustomize build local | kubectl apply -f -

Monitor progress:

    kubectl --namespace=kube-system get events --watch

Once it settles down, check whether it worked:

    kubectl get all

CouchDB can be contacted using

    curl -H localhost:5984/


Get CouchDB admin password:

    kubectl get secret couchdb-couchdb -o go-template='{{ .data.adminPassword }}' | base64 --decode


Make a GET command to couchdb that requires admin access (replace generated admin secret):

    curl http://admin:dZi2nSHIyPdxfallYOzp@127.0.0.1:5984/_all_dbs

There is a bug in the GitHub Docker registry that prevents containerd from
being able to pull images. k3d uses containerd so it is affected. As a workaround, you can:

1. [Log in to our private GitHub Docker registry](docker-login):

       cat ~/TOKEN.txt | docker login https://docker.pkg.github.com -u USERNAME --password-stdin

   You may need to create a personal access token first, see the linked
   instructions.

2. Pull down the image you want to deploy, e.g.:

       docker pull docker.pkg.github.com/cloud-71/web-app/web-app:11

3. Import the image into k3d:

       k3d import-images docker.pkg.github.com/cloud-71/web-app/web-app:11

4. Deploy the Kubernetes manifest (which should refer to the same tag as the
   one you used in the previous two steps):

       kustomize build local | kubectl apply -f -
        
[docker-login]: https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-docker-for-use-with-github-packages#authenticating-to-github-packages
[kustomize]: https://kustomize.io
