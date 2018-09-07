#!/bin/bash

release=$(lsb_release -is)
xdg=$XDG_CURRENT_DESKTOP

# echo "##################################"
# echo "###     Instalando Ansible     ###"
# echo "##################################"

#sudo apt update
#sudo apt upgrade
#sudo apt install -y software-properties-common
#sudo apt-add-repository ppa:ansible/ansible
#sudo apt install -y ansible

# echo "###################################"
# echo "###  Aplicando scripts Ansible  ###"
# echo "###################################"

# exec-ansible-playbook() {
#     echo "Executando o playbook $1"
#     ansible-playbook -k -b --ask-become-pass ansible/$1
# }

# exec-ansible-playbook basic-env-install.yml
# exec-ansible-playbook dev-env-install.yml
# exec-ansible-playbook tool-env-install.yml
# exec-ansible-playbook util-env-install.yml
# exec-ansible-playbook study-env-install.yml

#Docker Install
# exec-ansible-playbook docker-install.yml

#Ubuntu
if [[ $release = "Ubuntu" ]]; then
    echo "Instalando dependências especifica UBUNTU"
    # exec-ansible-playbook ubuntu-env-install.yml
elif [[ $release = "ManjaroLinux" ]]; then
  echo "Instalando dependências especifica MANJARO"
  #statements
fi

#GNOME
if [[ $xdg = *"GNOME"* ]];
then
    echo "Instalando dependências especifica GNOME"
    # exec-ansible-playbook gnome-env-install.yml
fi
