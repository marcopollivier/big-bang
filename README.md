# Pendencias 

## Estrutura

Adiciona Pastas
* /opt/ide
* /opt/tools

## Adiciona plugins no Oh My Zsh
```plugins=(git python mvn django docker git-flow ubuntu)```

## Adiciona nas variáveis de ambiente 
```
#USADO PELO JAVA
export JAVA_HOME="/usr/lib/jvm/current"
export PATH=$PATH:$JAVA_HOME/bin

#USADO PELO MAVEN
M2_HOME=/usr/lib/mvn/current
M2=$M2_HOME/bin
PATH=$M2:$PATH

#USADO PELO GRADLE
GRADLE_HOME=/usr/lib/gradle/current
GRADLE=$GRADLE_HOME/bin
PATH=$GRADLE:$PATH

#Altera Java
ALT_JAVA=/usr/lib/jvm
PATH=$ALT_JAVA:$PATH
```

## Uteis

* https://chaosmail.github.io/programming/2015/03/04/install-deb-packages-in-ansible/

---

## TODO - Analisar

* y-ppa-manager
* Vivaldi
* Google Drive

* Java 6, 7 e 8
* Maven
* Gradle

* Atom               https://atom.io/download/deb
* IntelliJ
* Eclipse

* Datagrip
    
* Slack              https://slack.com/downloads/linux

* Postman 		https://www.getpostman.com/


## Migrados para Imagens Docker

* postgresql 	- docker pull postgres
* mongodb 		- docker pull mongo
* mysql 		- docker pull mysql
* RabbitMQ 		- docker pull rabbitmq

----

## Ferramentas que adicionam source

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
## Ferramentas via WGET

### Google Chrome 
sudo dpkg -i "$(wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O -)"
rm google-chrome*

### Teamviewer
sudo dpkg -i "$(wget https://download.teamviewer.com/download/teamviewer_i386.deb  -O -)"
rm teamviewer*

### Git Kraken
sudo dpkg -i "$(wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -O -)"
rm gitkraken*

### Oh My Zsh
sudo sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

---

```
    apt_install skype

    #LaTex
    apt_install texlive 
    apt_install texlive-latex-extra 
    apt_install texlive-lang-portuguese 
    apt_install texlive-math-extra
    apt_install kile  
    apt_install kile-i18n-ptbr

    #Python
    apt_install python-django 
    apt_install python-pip 
    apt_install python3-pip
    pip install django
    pip3 install django

    apt_install nodejs
    ln -s /usr/bin/nodejs /usr/bin/node
    apt_install npm
    npm install -g bower
```
---

## Gnome Extensions
- https://extensions.gnome.org/extension/19/user-themes/
- https://extensions.gnome.org/extension/723/pixel-saver/
- https://extensions.gnome.org/extension/906/sound-output-device-chooser/
- https://extensions.gnome.org/extension/120/system-monitor/
- https://extensions.gnome.org/extension/1194/show-desktop-button/
- https://extensions.gnome.org/extension/7/removable-drive-menu/
- https://extensions.gnome.org/extension/779/clipboard-indicator/
- https://extensions.gnome.org/extension/307/dash-to-dock/
- https://extensions.gnome.org/extension/517/caffeine/
- https://extensions.gnome.org/extension/131/touchpad-indicator/

