#!/usr/bin/env python3

# Adapted from https://raw.githubusercontent.com/ansible/ansible/stable-2.9/contrib/inventory/openstack_inventory.py

# Copyright (c) 2012, Marco Vito Moscaritolo <marco@agavee.com>
# Copyright (c) 2013, Jesse Keating <jesse.keating@rackspace.com>
# Copyright (c) 2015, Hewlett-Packard Development Company, L.P.
# Copyright (c) 2016, Rackspace Australia
#
# This module is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this software.  If not, see <http://www.gnu.org/licenses/>.

import sys
from distutils.version import StrictVersion
from io import StringIO

import openstack as sdk
from openstack.cloud import inventory as sdk_inventory
from openstack.config import loader as cloud_config

CONFIG_FILES = ['/etc/ansible/openstack.yaml', '/etc/ansible/openstack.yml']


def append_hostvars(hostvars, server, namegroup=False):
    hostvars[key] = dict(
        ansible_ssh_host=server['interface_ip'],
        ansible_host=server['interface_ip'],
        openstack=server)


def get_host_groups_from_cloud(inventory):
    list_args = {}
    if hasattr(inventory, 'extra_config'):
        use_hostnames = inventory.extra_config['use_hostnames']
        list_args['expand'] = inventory.extra_config['expand_hostvars']
        if StrictVersion(sdk.version.__version__) >= StrictVersion("0.13.0"):
            list_args['fail_on_cloud_config'] = \
                inventory.extra_config['fail_on_errors']
    else:
        use_hostnames = False

    server_ips = []
    for server in inventory.list_hosts(**list_args):
        server_ips.append(server['interface_ip'])

    return server_ips


def main():
    try:
        # openstacksdk library may write to stdout, so redirect this
        sys.stdout = StringIO()
        config_files = cloud_config.CONFIG_FILES + CONFIG_FILES
        inventory_args = {}
        if hasattr(sdk_inventory.OpenStackInventory, 'extra_config'):
            inventory_args.update(dict(
                config_key='ansible',
                config_defaults={
                    'use_hostnames': False,
                    'expand_hostvars': False,
                    'fail_on_errors': True,
                }
            ))

        inventory = sdk_inventory.OpenStackInventory(**inventory_args)

        sys.stdout = sys.__stdout__

        # Write the new hosts.ini file
        server_ips = get_host_groups_from_cloud(inventory)
        with open('ansible/inventory/hosts.ini', 'w+') as f:
            f.write('[master]\n')
            f.write(server_ips[0] + '\n')
            f.write('[node]\n')
            for i in server_ips[1:]:
                f.write(i + '\n')
            f.write('[k3s-cluster:children]\n')
            f.write('master\n')
            f.write('node\n')


    except sdk.exceptions.OpenStackCloudException as e:
        sys.stderr.write('%s\n' % e.message)
        sys.exit(1)
    sys.exit(0)


if __name__ == '__main__':
    main()
