# Kubernetes manifests

We are using kubectl to deploy our Kubernetes resources, k3d to test changes
locally on our computers, and [Kustomize][kustomize] to adapt our manifests for
local development and cloud deployment. You can install them using:

    brew install k3d kustomize kubectl

[base](./base) contains shared resources that are useful locally as well as in
the cloud, e.g. our web app, Twitter harvester, AURIN downloader, and CouchDB
cluster.

The [local](./local) variant references the shared resources, and patches the
CouchDB deployment to add an ingress for ease of development.

The [cloud](./cloud) variant adds a PodPreset that configures the University of
Melbourne proxy settings necessary to run on the `qh2-uom-internal` network.
This variant is useful for projects that don't have access to external volumes.

[cloud-with-volumes](./cloud-with-volumes) further extends the cloud variant
with a Cinder storage provider that is used to attach external volumes to
CouchDB.

## Secrets

Before anything can can be deployed, Kubernetes requires access to the
following credentials:

* A personal access token for our private GitHub Docker image registry, which
  is used as an `imagePullSecret`

* An OpenStack Application Credential with privileges to create Cinder Volumes
  (only needed when deploying the `cloud-with-volumes` variant)

* A Twitter API key to use for harvesting tweets

* An AURIN API key to use for downloading datasets

The `./kustomize_build` script harnesses a [Kustomize plugin][plugin] that
extracts these secrets from the OpenStack Barbican key manager and transforms
them into Kubernetes `Secret` resource manifests. We have defined a
[`BarbicanSecret` manifest](./base/barbican-secret-generator.yml) that
specifies which secrets should be extracted.

We assume that the relevant Barbican secrets [have been created](./SECRETS.md).
Ensure you have sourced the relevant cloud credentials before proceeding.

## Deploy to a Kubernetes cluster

1. First, [provision a K3s cluster using Ansible](../ansible). Then, ensure you
   have exported your `KUBECONFIG` environment variable. The command to do this
   is printed in the last step of the playbook.  Use `kubectl cluster-info` to
   debug this.

2. If you are using to your personal project, you can deploy all Kubernetes
   manifests using:

       ./kustomize_build.sh cloud | kubectl apply -f -

   If you want CouchDB to store its data in OpenStack Cinder volumes, which are
   only available in the group project, use:

       ./kustomize_build.sh cloud-with-volumes | kubectl apply -f -

3. Monitor progress:

       kubectl get events --all-namespaces --watch

## Local development

1. Set up a development cluster on your local machine using

       k3d create --publish 5984:5984 --server-arg=disable=traefik
       export KUBECONFIG=$(k3d get-kubeconfig)

2. There is a bug in the GitHub Docker registry that prevents `containerd` from
   being able to pull images. k3d uses `containerd` so it is affected. As a
   workaround, you can [log in to our private Docker registry][docker-login]:

       cat ~/TOKEN.txt | docker login https://docker.pkg.github.com -u USERNAME --password-stdin

   You may need to create a personal access token first, see the linked
   instructions.

3. Pull down the images:

       docker pull docker.pkg.github.com/cloud-71/web-app/web-app \
                   docker.pkg.github.com/cloud-71/twitter-harvester/twitter-harvester \
                   docker.pkg.github.com/cloud-71/aurin-harvester/aurin-harvester

4. Import the images into k3d:

       k3d import-images docker.pkg.github.com/cloud-71/web-app/web-app \
                         docker.pkg.github.com/cloud-71/twitter-harvester/twitter-harvester \
                         docker.pkg.github.com/cloud-71/aurin-harvester/aurin-harvester

5. Deploy the Kubernetes manifests:

       ./kustomize_build.sh local | kubectl apply -f -

6. Monitor progress:

       kubectl get events --all-namespaces --watch

7. Once the dust settles, check whether it worked:

       kubectl get all

8. CouchDB can be contacted using

       curl -H localhost:5984/

9. Get CouchDB admin password:

       kubectl get secret couchdb-couchdb -o go-template='{{ .data.adminPassword }}' | base64 --decode

10. Make a GET command to couchdb that requires admin access (replace generated admin secret):

        curl http://admin:dZi2nSHIyPdxfallYOzp@127.0.0.1:5984/_all_dbs

[docker-login]: https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-docker-for-use-with-github-packages#authenticating-to-github-packages
[kustomize]: https://kustomize.io
[gh-token]: https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
[plugin]: ./kustomize_plugins/group71/barbicansecret/BarbicanSecret
