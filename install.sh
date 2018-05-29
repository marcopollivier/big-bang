#!/bin/bash

echo "##################################"
echo "###     Instalando Ansible     ###"
echo "##################################"

sudo apt update
sudo apt upgrade
sudo apt install -y software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt install -y ansible

echo "###################################"
echo "###  Aplicando scripts Ansible  ###"
echo "###################################"

ansible-playbook -k -b --ask-become-pass ansible/basic-env-install.yml
ansible-playbook ansible/dev-env-install.yml
ansible-playbook ansible/tool-env-install.yml
ansible-playbook ansible/util-env-install.yml
ansible-playbook ansible/study-env-install.yml

#Docker Install
ansible-playbook ansible/docker-install.yml

#Ubuntu
if [ $(lsb_release -is) = "Ubuntu" ]
then
    echo "Dependencia especifica Ubuntu"
    ansible-playbook ansible/ubuntu-env-install.yml
fi

#Ubuntu GNOME
if [ $XDG_CURRENT_DESKTOP = "ubuntu:GNOME" ]
then
    echo "Dependencia especifica Gnome"
    ansible-playbook ansible/gnome-env-install.yml
fi

