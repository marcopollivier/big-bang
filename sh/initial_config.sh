#!/bin/bash

##### pendencias 
#Atom - https://atom.io/download/deb

#DevTools - http://www.diolinux.com.br/2015/07/como-instalar-o-android-studio-no-ubuntu-corretamente.html#sthash.AGYOjSQG.dpuf

#Java

#y-ppa-manager
#Android Studio
#Sublimetext
#Eclipse
#Vivaldi
#Google Drive
#PostgreSQL
#DBeaver

#teamviewer

##### 

##############################################################################
##############################################################################
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
##############################################################################
##############################################################################

apt_install() {
    local x=$1
    apt-get install -y $x
}

upgrade() {
    apt-get update
    apt-get upgrade -y
}

basic() {
    apt_install synaptic
    
    apt_install vim
}

utils() {
    apt_install bleachbit
    
    apt_install skype
    
    #TODO Revisar aqui
    #Google Chrome 
    #wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp/
    #dpkg -i /tmp/google-chrome-stable_current_amd64.deb
    #rm /tmp/google-chrome-stable_current_amd64.deb
    
    # Spotify
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    upgrade
    apt_install spotify-client
    
    #Teamviewer
    rm /tmp/teamviewer_i386*
    wget https://download.teamviewer.com/download/teamviewer_i386.deb -P /tmp/
    dpkg -i /tmp/teamviewer_i386.deb
    rm /tmp/teamviewer_i386*
}

ubuntu_unity_utils() {
    apt_install ubuntu-restricted-extras
    apt_install unity-tweak-tool
    
    apt_install nautilus-dropbox
}

academic() {
    #LaTex
    apt_install texlive 
    apt_install texlive-latex-extra 
    apt_install texlive-lang-portuguese 
    apt_install texlive-math-extra
    apt_install kile  
    apt_install kile-i18n-ptbr
}

study() {
    apt_install stellarium
}

infra() {
    apt_install filezilla
}

dev_ops() {
    #Git
    apt_install git

    echo "Enter Your Git Name: "
    read git_name
    git config --global user.name $git_name #TODO Revisar aqui

    echo "Enter Your Git E-mail: "
    read git_email
    git config --global user.email $git_email

    git config --list
      
    #Git Kraken
    rm /tmp/gitkraken-amd64*
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -P /tmp/
    dpkg -i /tmp/gitkraken-amd64.deb
    rm /tmp/gitkraken-amd64*
}

dev_backend() {
    #Python
    apt_install python-django 
    apt_install python-pip 
    apt_install python3-pip
    pip install django
    pip3 install django
}

dev_frontend() {
    apt_install nodejs
    ln -s /usr/bin/nodejs /usr/bin/node
    apt_install npm
    npm install -g bower
}

database() {
    #MongoDB
    apt_install mongodb

    #MySQL
    apt_install mysql-server-5.7 
    apt_install mysql-workbench
}

##############################################################################
##############################################################################
__init__() {
    upgrade
    #basic
    
    #utils
    #academic
    #study
    #infra
    #dev_ops
    #dev_backend
    #dev_frontend
    database
    
    #ubuntu_unity_utils
}

apt_install ansible

#futuramente essa parte do script vai ser substituída por um script ansible
__init__ 
##############################################################################
##############################################################################
