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

# ansible-playbook ansible/basic-env-install.yml

# ansible-playbook ansible/dev-env-install.yml
# ansible-playbook ansible/docker-install.yml

if [ $(lsb_release -is) = "Ubuntu" ]
then
    echo "Dependencia especifica Ubuntu"
    ansible-playbook ansible/ubuntu-based-env-install.yml
fi

if [ $XDG_CURRENT_DESKTOP = "ubuntu:GNOME" ]
then
    echo "Dependencia especifica Gnome"
    ansible-playbook ansible/ubuntu-gnome-based-env-install.yml
fi

