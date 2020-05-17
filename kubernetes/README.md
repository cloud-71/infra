## K3D Setup Instructions

Set up a dev cluster on your local machine using

    brew install k3d
    k3d create --publish 5984:5984 --server-arg=disable=traefik
    export KUBECONFIG=$(k3d get-kubeconfig)

Set up the ingress controller using

    kubectl apply -f kubernetes/haproxy-ingress.yml

Install CouchDB using

    kubectl apply -f kubernetes/couchdb-dev.yml

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

       kubectl apply -f web-app.yml
        
[docker-login]: https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-docker-for-use-with-github-packages#authenticating-to-github-packages
