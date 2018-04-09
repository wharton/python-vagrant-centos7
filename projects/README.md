# SEPIA Ansible Playbooks and Roles

This repository holds Ansible playbooks and roles for configuring SEPIA servers.

## Getting started

Clone this repository.

    git clone git@github.com:FlipperPA/sepia-ansible.git
    cd sepia-ansible

Deploy the dev environment:

    ansible-playbook playbooks/web-py.yml

Show some servers:

    ansible centos-7 --list-hosts
    ansible web-py --list-hosts

Run some commands; `shell` is required for arguments and shell functions (`command` runs without the target user's shell):

    ansible all -m command -a uptime -i inventory
    ansible all -m shell -oa 'ps -eaf'
    ansible rhel-7 -m copy -a 'content="Welcome to SEPIA, Ansiblized.\n" dest=/etc/motd' -u apache --become --become-user root

Documentation: list help section, show documentation for specific command (with examples!):

    ansible-doc -l
    ansible-doc yum

## Web Development

Users who wish to do on-server development must be added to the Ansible role in `roles/web_dev_tools/vars/main.yml`. This will create them a development directory on the SEPIA development servers and a `projects` symlink in their home directory to it.
