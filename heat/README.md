## Heat

We are using [OpenStack Heat][heat] to provision our infrastructure.

Please refer to the [example templates][heat-examples] and [Resource Type reference][heat-ref].

In the instructions below, <name> is arbitrary and chosen by **you**.

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

[heat]: https://wiki.openstack.org/wiki/Heat
[heat-examples]: https://github.com/openstack/heat-templates
[heat-ref]: https://docs.openstack.org/heat/train/template_guide/openstack.html
