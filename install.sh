#!/bin/bash

function pre_config() {
    if [[ $release = "Ubuntu" ]]; then

        echo "not implemented"
        #sudo apt list --installed | grep -i apache

        #sudo apt update
        #sudo apt upgrade
        #sudo apt install -y software-properties-common
        #sudo apt-add-repository ppa:ansible/ansible
        #sudo apt install -y ansible

    elif [[ $release = "ManjaroLinux" ]]; then

        if pacman -Qs ansible > /dev/null ; then
          sudo pacman -Syu
          sudo pacman -S ansible --noconfirm
        fi

    fi
}

if [ -z "$1" -o  $# -lt 2 ]; then
    echo "Nenhum argumento informado e/ou argumento(s) vazios ou nulos"
    echo "      ./$(basename $0) <nome do usuario git> <email usuario git>"
    echo ""
    echo "      ./$(basename $0) 'Fulano da Silva' 'fulano@gmail.com'"
else
    echo "#############################################################"
    echo "           Configurando ambiente de dev no host $name        "
    echo "#############################################################"
    echo ""

    pre_config

    HOSTNAME=$(uname -n)            # nome do host da máquina
    USERNAME=$(id -u -n)            # nome do usuario autenticado
    DISTRONAME=$(lsb_release -is)   # nome da distro Ex.: Ubuntu, ManjaroLinux
    XDGNAME=$XDG_CURRENT_DESKTOP    # nome da interface grafica usada Ex.: GNOME

    GITNAME=$1
    GITEMAIL=$2

    echo "# DISTRONAME: $DISTRONAME"
    echo "# USERNAME: $USERNAME"
    echo "# XDGNAME: $XDGNAME"
    echo "# GITNAME: $GITNAME"
    echo "# GITEMAIL: $GITEMAIL"

    echo -n "Are you sure? [ENTER]"
    read SURE

    ansible-playbook \
    -e var_deploy_release="$DISTRONAME" \
    -e var_deploy_user="$USERNAME" \
    -e var_deploy_xdg="$XDGNAME" \
    -e var_deploy_git_name="$GITNAME" \
    -e var_deploy_git_email="$GITEMAIL" \
    -k -b --ask-become-pass \
    ansible/install.yml

fi