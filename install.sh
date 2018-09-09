#!/bin/bash

name=$(uname -n)
user=$(id -u -n)
release=$(lsb_release -is)
xdg=$XDG_CURRENT_DESKTOP

echo "##########################################################"
echo "###     Configurando ambiente de dev no host $name     ###"
echo "##########################################################"

#sudo apt update
#sudo apt upgrade
#sudo apt install -y software-properties-common
#sudo apt-add-repository ppa:ansible/ansible
#sudo apt install -y ansible

#Ubuntu
# if [[ $release = "Ubuntu" ]]; then
#     echo "Instalando dependências especifica $release"
# elif [[ $release = "ManjaroLinux" ]]; then
#   echo "Instalando dependências especifica $release"
# fi

#GNOME
# if [[ $xdg = *"GNOME"* ]];
# then
#     echo "Instalando dependências especifica GNOME"
#     # exec-ansible-playbook gnome-env-install.yml
# fi

ansible-playbook \
-e var_deploy_release=$release \
-e var_deploy_user=$user \
-e var_deploy_git_name='Marco Ollivier' \
-e var_deploy_git_email='marcopollivier@gmail.com' \
-k -b --ask-become-pass \
ansible/install.yml
