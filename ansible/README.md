# Pendencias 

* DevTools - http://www.diolinux.com.br/2015/07/como-instalar-o-android-studio-no-ubuntu-corretamente.html#sthash.AGYOjSQG.dpuf

* y-ppa-manager
* Vivaldi
* Google Drive

* Java 6, 7 e 8
* Maven
* Gradle

* Atom               https://atom.io/download/deb
* Sublime            https://www.sublimetext.com/3
* IntelliJ
* Eclipse

* Datagrip
    
* Slack              https://slack.com/downloads/linux
* Teamviewer

* https://chaosmail.github.io/programming/2015/03/04/install-deb-packages-in-ansible/

* https://www.spotify.com/br/download/linux/
* https://slack.com/downloads/linux
* https://www.gitkraken.com/download/linux-deb
* https://atom.io/

## Migrados para Imagens Docker

* postgresql 	- docker pull postgres
* mongodb 		- docker pull mongo
* mysql 		- docker pull mysql
* RabbitMQ 		- docker pull rabbitmq

----

```
# 1. Add the Spotify repository signing keys to be able to verify downloaded packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410

# 2. Add the Spotify repository
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

# 3. Update list of available packages
sudo apt-get update

# 4. Install Spotify
sudo apt-get install spotify-client



# 1. Install the GPG key:
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

# 2. Ensure apt is set up to work with https sources:
sudo apt-get install apt-transport-https

# 3. Add the Sublime repository
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# 4. Update apt sources and install Sublime Text
sudo apt-get update

# 5. Install Sublime
sudo apt-get install sublime-text

```

---

```
utils() {
   
    apt_install skype
    
    #TODO Revisar aqui
    #Google Chrome 
    #wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp/
    #dpkg -i /tmp/google-chrome-stable_current_amd64.deb
    #rm /tmp/google-chrome-stable_current_amd64.deb
    
    #Teamviewer
    #rm /tmp/teamviewer_i386*
    #wget https://download.teamviewer.com/download/teamviewer_i386.deb -P /tmp/
    #dpkg -i /tmp/teamviewer_i386.deb
    #rm /tmp/teamviewer_i386*

    # Spotify
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    upgrade
    apt_install spotify-client 
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

dev_ops() {
      
    #Git Kraken
    #rm /tmp/gitkraken-amd64*
    #wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -P /tmp/
    #dpkg -i /tmp/gitkraken-amd64.deb
    #rm /tmp/gitkraken-amd64*
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
```

