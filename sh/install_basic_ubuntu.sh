#TODO
#Java
#Front JS
#Eclipse
#Chrome
#Vivaldi
#Spotify
#Sublime
#Atom
#Android Studio
#PostgreSQL

sudo apt-get install texlive texlive-latex-extra texlive-lang-portuguese 
sudo apt-get install texlive-math-extra

sudo apt-get install kile  
sudo apt-get install kile-i18n-ptbr

## Basic
	add-apt-repository ppa:webupd8team/y-ppa-manager
	apt-get update
	apt-get install y-ppa-manager

## Personal
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	dpkg -i google-chrome-stable_current_amd64.deb
	rm google-chrome-stable_current_amd64.deb

## Desenv
	wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
	dpkg -i gitkraken-amd64.deb
	rm gitkraken-amd64.deb

	#Python
	apt-get install -y python-django python-pip python3-pip
	pip install django
	pip3 install django

	#Android
	add-apt-repository ppa:ubuntu-desktop/ubuntu-make -y
	apt-get update
	apt-get install ubuntu-make -y #See more at: http://www.diolinux.com.br/2015/07/como-instalar-o-android-studio-no-ubuntu-corretamente.html#sthash.AGYOjSQG.dpuf
	umake android
	sudo apt-get install android-tools-adb
	umake android --remove

	#DevTools
	add-apt-repository ppa:ubuntu-desktop/ubuntu-make
	apt-get update
	apt-get install -y ubuntu-make
