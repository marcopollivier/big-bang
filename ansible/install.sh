#!/bin/bash

sudo apt update
sudo apt upgrade
sudo apt install -y software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt install -y ansible

ansible-playbook basic-env-intstall.yml

ansible-playbook ubuntu-based-env-intstall.yml

ansible-playbook dev-env-intstall.yml
ansible-playbook docker-install.yml
