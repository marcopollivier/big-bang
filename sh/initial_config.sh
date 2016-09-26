#!/bin/bash

# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

## Basic
basic () {
	apt-get install -y synaptic
	apt-get install -y bleachbit
	apt-get install -y ubuntu-restricted-extras
	apt-get install -y unity-tweak-tool

	apt-get install -y vim

	add-apt-repository ppa:webupd8team/y-ppa-manager
	apt-get update
	apt-get install y-ppa-manager
}


## Personal
personal() {
	apt-get install -y nautilus-dropbox

	apt-get install -y gtk2-engines-murrine:i386 gtk2-engines-pixbuf:i386
	apt-get install -y skype

	#wget https://download.sublimetext.com/sublime-text_build-3103_amd64.deb
	#dpkg -i sublime-text_build-3103_amd64.deb
	#rm sublime-text_build-3103_amd64.deb

	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	dpkg -i google-chrome-stable_current_amd64.deb
	rm google-chrome-stable_current_amd64.deb
}

## Desenv
desenv() {
	#Java via apt-get
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get install oracle-java8-installer
	sudo apt-get install oracle-java8-set-default

	#Git
	apt-get install -y build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip
	apt-get install -y git

	#echo "Enter Your Git Name: "
	#read git_name
	#git config --global user.name $git_name

	#echo "Enter Your Git E-mail: "
	#read git_email
	#git config --global user.email $git_email

	git config --list

	wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
	dpkg -i gitkraken-amd64.deb
	rm gitkraken-amd64.deb

	#Python
	apt-get install -y python-django python-pip python3-pip
	pip install django
	pip3 install django

	#Front JS
	apt-get install -y nodejs
	ln -s /usr/bin/nodejs /usr/bin/node
	apt-get install -y npm
	npm install -g bower

	#MySQL
	apt-get install -y mysql-server-5.7 mysql-workbench

	#Android
	add-apt-repository ppa:ubuntu-desktop/ubuntu-make -y
	apt-get update
	apt-get install ubuntu-make -y #See more at: http://www.diolinux.com.br/2015/07/como-instalar-o-android-studio-no-ubuntu-corretamente.html#sthash.AGYOjSQG.dpuf
	umake android
	sudo apt-get install android-tools-adb
	umake android --remove

	#MongoDB
	apt-get install -y mongodb

	#FTP
	apt-get install -y filezilla

	#DevTools
	add-apt-repository ppa:ubuntu-desktop/ubuntu-make
	apt-get update
	apt-get install -y ubuntu-make
}

## Study
study() {
	apt-get install -y stellarium
}

## Pre Configuration
__init__() {
	apt-get update
	apt-get upgrade -y

	basic
	personal
	desenv
	study
}

__init__


#TODO
#Eclipse
#Chrome
#Skype
#Vivaldi
#Dropbox
#Google Drive
#Spotify
#Atom
#Android Studio
#Mongo
#PostgreSQL
