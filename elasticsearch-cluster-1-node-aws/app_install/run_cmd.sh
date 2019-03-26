#!/bin/bash
. $(dirname $(readlink -f "main.tf"))/values.sh

chmod 400 $(dirname $(readlink -f "main.tf"))/keys/*
export ANSIBLE_CONFIG=$(dirname $(readlink -f "main.tf"))/ansible.cfg
ansible-playbook -vvvv --user=$ssh_user -i $(dirname $(readlink -f "main.tf"))/hosts --key-file=$(dirname $(readlink -f "main.tf"))/keys/$ssh_key_name.pem $(dirname $(readlink -f "main.tf"))/ansible/playbook_config.yml
ansible-playbook -vvvv --user=$ssh_user -i $(dirname $(readlink -f "main.tf"))/hosts --key-file=$(dirname $(readlink -f "main.tf"))/keys/$ssh_key_name.pem $(dirname $(readlink -f "main.tf"))/ansible/playbook.yml
