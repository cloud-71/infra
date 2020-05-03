# infra
The ansible stuff and CouchDB Kubernetes template

# K3D Setup Instructions

Set up a dev cluster using

    brew install k3d
    k3d create --publish 5984:80 --workers=3
    export KUBECONFIG=$(k3d get-kubeconfig)

Install CouchDB using

    kubectl apply -f couchdb.yml

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
 
