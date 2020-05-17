## Heat

We are using [OpenStack Heat][heat] to provision our infrastructure.

Please refer to the [example templates][heat-examples] and [Resource Type reference][heat-ref].

1. [Obtain password](https://dashboard.cloud.unimelb.edu.au/settings/reset-password/) from MRC dashboard (reset is fine).

2. [Download](https://dashboard.cloud.unimelb.edu.au/project/api_access/openrc/) and source the OpenStack RC file, when prompted enter password from step 1

       source ~/Downloads/unimelb-comp90024-2020-grp-71-openrc

3. Delete any previous stacks

       openstack stack list
       openstack stack delete <name>

4. If it get stuck, delete any remaining instances:

       openstack server list
       openstack server delete <id>

5. Choose a name for your new stack:

       export STACK_NAME=my-awesome-stack

6. Create the new stack

       openstack stack create --template cluster.yaml --environment cluster.params.yaml ${STACK_NAME}

7. Copy the private key

       openstack stack output show -f json ${STACK_NAME} private_key | jq -r '.output_value' > ${HOME}/.ssh/id_group71
       chmod 600 ~/.ssh/id_group71

[heat]: https://wiki.openstack.org/wiki/Heat
[heat-examples]: https://github.com/openstack/heat-templates
[heat-ref]: https://docs.openstack.org/heat/train/template_guide/openstack.html
