#!/bin/bash

echo "##################################"
echo "###     Instalando Ansible     ###"
echo "##################################"

#sudo apt update
#sudo apt upgrade
#sudo apt install -y software-properties-common
#sudo apt-add-repository ppa:ansible/ansible
#sudo apt install -y ansible

echo "###################################"
echo "###  Aplicando scripts Ansible  ###"
echo "###################################"

exec-ansible-playbook() {
    echo "Executando o playbook $1"
    ansible-playbook -k -b --ask-become-pass ansible/$1
}

exec-ansible-playbook basic-env-install.yml
exec-ansible-playbook dev-env-install.yml
exec-ansible-playbook tool-env-install.yml
exec-ansible-playbook util-env-install.yml
exec-ansible-playbook study-env-install.yml

#Docker Install
exec-ansible-playbook docker-install.yml

#Ubuntu
if [ $(lsb_release -is) = "Ubuntu" ]
then
    echo "Dependencia especifica Ubuntu"
    exec-ansible-playbook ubuntu-env-install.yml
fi

#Ubuntu GNOME
if [ $XDG_CURRENT_DESKTOP = "ubuntu:GNOME" ]
then
    echo "Dependencia especifica Gnome"
    exec-ansible-playbook gnome-env-install.yml
fi

